# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2010 - 2011  Timin Aleksey
# Copyright (C) 2010  Kelley Reynolds
# Copyright (C) 2012 uCratos Ltd (Steve Gooberman-Hill)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

module ModBus
  module RTU
    private

    # We have to read specific amounts of numbers of bytes from the network depending on the function code and content
    # this only varies from the rread_rtu_request method by the message length handling
    # TODO - combine the two methods with a callout to a block to get the content length?
    def read_rtu_response(io=nil)
      #note that by default we use the internal @io, but being able to pass an io in makes testing easier
      io||=@io
      uid=nil
	    function_code=nil
      msg_length=nil
      msg_content=nil
      
      msg=nil
      
      timer=io.read_timeout
      select_timer=timer.to_f/1000 #select timer is in seconds, @io_read_timeout is in ms
      
      
      begin
        io.read_timeout=-1
                  
        #first read slave ID and Function Code
        #there is no timeout in the caller as it is dangerous (see http://headius.blogspot.co.uk/2008/02/rubys-threadraise-threadkill-timeoutrb.html)
        #so the read and write timeing is handled using select calls
        
        #allow a decent interval for the first octet - the device has to respond!
        #we should always get five bytes minimum as this is the length of an error code (uid, function code, error code, 2 byte CRC)
        
        begin
          #explicitly raise an error if we can't contact the device
          raise ModBus::Errors::ModBusTimeout, 'Device does not respond' unless read_ready?(select_timer)
          uid = io.sysread(1)
        rescue SystemCallError, Errno::EAGAIN, EOFError => er
          $log.debug 'Rx : read error ' + er.to_s
          #next line will catch
        end
        raise ModBus::Errors::ProtocolError, "Incomplete Slave ID read" unless uid 
        
        #now we have a response so we can continue      
        #we will always read the entire message - a slave ID mismatch is handled at a higher level 
        begin
          function_code = io.sysread(1) if read_ready?(io.t_3_5)
        rescue SystemCallError, Errno::EAGAIN, EOFError => er
          $log.debug 'Rx : read error ' + er.to_s
          #next line will catch
        end 
        raise ModBus::Errors::ProtocolError, "Incomplete Function Code read" unless function_code 
        
        #how much more we read is dependent on the function code - some function codes have fixed length responses
        #for others we read bytes to find the length of the response
        content_length=0
        case function_code.getbyte(0)
        when 1,2,3,4 then
          # read the third byte to find out how much more
          # we need to read + CRC
          begin
            msg_length= io.sysread(1) if read_ready?(io.t_3_5)
          rescue SystemCallError, Errno::EAGAIN, EOFError => er
            $log.debug 'Rx : read error ' + er.to_s
            #next line will catch
          end 
          raise ModBus::Errors::ProtocolError, "Incomplete Message Length read" unless msg_length 
          content_length=msg_length.getbyte(0)+2
          
        when 5,6,15,16 then
          # We just read in an additional 6 bytes
          content_length=6
        when 22 then
          content_length=8
        when 0x80..0xff then
          #error response- so we expect 3 more bytes
          content_length=3
        else
          
          #what to do if we can't recognise the return sequence?
          #this method is only ever called at the master end, so we should probably
          #just read any remaining bytes on the interface, then end
          raise ModBus::Errors::IllegalFunction, "Illegal function: #{function_code}"
        end
        
        begin
          #check again that there is data to read
          msg_content=''
          while msg_content.bytesize < content_length && read_ready?(io.t_3_5)
            msg_content+=io.sysread(content_length-msg_content.bytesize)
          end
                 
        rescue SystemCallError, Errno::EAGAIN, EOFError => er
          $log.debug 'Rx : read error ' + er.to_s
          #next line will catch
        end
        raise ModBus::Errors::ProtocolError, "Incomplete Message Content read" unless msg_content && msg_content.bytesize==content_length
        
        msg_length ||= ''
        msg=uid+function_code+msg_length+msg_content
      
      rescue ModBus::Errors::ModBusException =>er
        raise er if er.kind_of? ModBus::Errors::ModBusTimeout
        
        uid ||= ''
        function_code ||= ''
        msg_length ||= ''
        msg_content ||= ''
        
        msg=uid+function_code+msg_length+msg_content
              
        
        $log.debug 'Rx : '+er.message+ ' ' + logging_bytes(msg)
         
        
        msg='' # return an empty message  
      rescue StandardError => er
        $log.error "Rx : Device Failed due to #{er}"
        raise
                
      ensure
        io.read_timeout=timer
        msg 
                    
        end
    end
    
    # clear the buffer - need to ensure that there is nothing in the buffer both before we start a query
    # and after we finish a query - some devices are known to give multiple responses (eg a good response and an
    # error response as well), or a timeout could have been missed because the device was too slow
    def clear_buffer
      #log("Rx : clearing buffer")
      residual=''
      timer=@io.read_timeout
              
      begin
        @io.read_timeout=-1
        if read_ready?(@io.t_3_5)
          loop do
            residual  <<  @io.readchar  #get residual if there is anything left
            break unless read_ready?(@io.t_3_5)
          end
        end
      rescue SystemCallError, Errno::EAGAIN, EOFError => er
        $log.debug 'Rx : clear buffer error ' + er.to_s
      ensure
        @io.read_timeout=timer
        $log.debug 'Rx : clear_buffer ' + logging_bytes(residual) 
        nil #
      end 
      

    end

    #send a PDU 
    def send_rtu_pdu(pdu)
      msg = @uid.chr + pdu
      msg << crc16(msg).to_word

      timer=@io.read_timeout
      select_timer=timer.to_f/1000 #select timer is in seconds, @io_read_timeout is in ms

      
      #check the buffer is ready to write
      begin
        raise ModBus::Errors::ModBusTimeout, 'Device not ready' unless write_ready?(select_timer)        
        length=@io.syswrite(msg)
      rescue SystemCallError => er
        $log.debug 'Tx : write error '+er.to_s
      rescue Exception => ex
        $log.debug 'Tx : write exception '+ ex.to_s 
        raise
        #next line will catch
      end
      raise ModBus::Errors::ProtocolError, "Incomplete Message sent #{length}" unless length==msg.bytesize
      

      #$log.debug "Tx (#{msg.bytesize} bytes): " + logging_bytes(msg)
        log "Tx (#{msg.bytesize} bytes): " + logging_bytes(msg)
    end

    #read a PDU response from the device
    #TODO should CRC mismatches or UID mismatches raise as errors?
    def read_rtu_pdu
      msg = read_rtu_response(@io)

#      $log.debug "Rx (#{msg.bytesize} bytes): " + logging_bytes(msg)
      log "Rx (#{msg.bytesize} bytes): " + logging_bytes(msg)

      if msg.getbyte(0) == @uid
        return msg[1..-3] if msg[-2,2].unpack('n')[0] == crc16(msg[0..-3])
           
        #only get here if CRC is wrong  
        $log.debug "Ignore package: don't match CRC"
      else
        $log.debug "Ignore package: don't match uid ID"
      end
      
      #return nil if no valid pdu read
      nil
      
    end

    #read an RTU request
    def read_rtu_request(io=nil)
      io||=@io
      $log.debug 'Rx : started'
      uid=nil
      function_code=nil
      msg_length=nil
      msg_content=nil
      
      msg=nil
      
      timer=io.read_timeout
      select_timer=timer.to_f/1000 #select timer is in seconds, io_read_timeout is in ms
            
      
      begin
        io.read_timeout=-1
                  
        #first read slave ID and Function Code
        #there is no timeout in the caller as it is dangerous (see http://headius.blogspot.co.uk/2008/02/rubys-threadraise-threadkill-timeoutrb.html)
        #so the read and write timeing is handled using select calls
        
        #allow a decent interval for the first octet - the device has to respond!
        #we should always get eight bytes minimum as this is the length of the shortest normal request
        #TODO - check diagnostics request length - but we have at least 3 bytes so should be fine
        
        begin
          raise ModBus::Errors::ModBusTimeout, 'Device does not respond' unless read_ready?(select_timer)
          uid = io.sysread(1)
        rescue SystemCallError, EOFError, Errno::EAGAIN
          #next line will catch
        end
        raise ModBus::Errors::ProtocolError, "Incomplete Slave ID read" unless uid #&& msg_header.bytesize==2
        
        #now we have a response so we can continue      
        #we will always read the entire message - a slave ID mismatch is handled at a higher level 
        begin
          function_code = io.sysread(1) if read_ready?(io.t_3_5)
        rescue SystemCallError, EOFError, Errno::EAGAIN
          #next line will catch
        end 
        raise ModBus::Errors::ProtocolError, "Incomplete Function Code read" unless function_code 
        
        #how much more we read is dependent on the function code - some function codes have fixed length responses
        #for others we read bytes to find the length of the response
        content_length=0
  			case function_code.getbyte(0)
  			when 1, 2, 3, 4, 5, 6
  			  content_length=6
  			when 15, 16
  				# Read in first register (2 bytes), register count (2 bytes), and data bytes (1 byte)
  				msg_length = io.sysread(5) if read_ready?(io.t_3_5*5)
          raise ModBus::Errors::ProtocolError, "Incomplete Message Length read" unless msg_length.bytesize==5
          content_length=msg_length.getbyte(4)+2
        else
          #TODO - add diagnostics processing
          raise ModBus::Errors::IllegalFunction, "Illegal function: #{function_code}"
        end            
  				
  				
        begin
          #check again that there is data to read
          msg_content=''
          while msg_content.bytesize < content_length && read_ready?(select_timer)
            msg_content+=@io.sysread(content_length-msg_content.bytesize)
          end        
        rescue SystemCallError, EOFError, Errno::EAGAIN
        #next line will catch
        end
        raise ModBus::Errors::ProtocolError, "Incomplete Message Content read" unless msg_content && msg_content.bytesize==content_length
        
        msg_length ||= ''
        msg=uid+function_code+msg_length+msg_content
      
        rescue ModBus::Errors::ModBusException =>er
          raise er if er.kind_of? ModBus::Errors::ModBusTimeout
          
          uid ||= ''
          function_code ||= ''
          msg_length ||= ''
          msg_content ||= ''
          
          msg=uid+function_code+msg_length+msg_content
                
          
          $log.debug 'Rx : '+er.message+ ' ' + logging_bytes(msg)
           
          
          msg='' # return an empty message  
        ensure
          io.read_timeout=timer
          msg 
                      
        end
		end

    #serve an RTU request
		#TODO - do we want to flag a bad CRC check as an error - it may be good to log it so we can get an idea
		#of just how bad the line is!
		def serv_rtu_requests(io, &blk)
      loop do
        # read the RTU message
        begin
          msg = read_rtu_request(io)
          $log.debug "Rx : " +logging_bytes(msg)
                
        rescue ModBus::Errors::ModBusException
          #if the read fails then we get here
        end
        # If there is no RTU message, then loop! we're NOT! done serving this client
        next if msg.nil?

        if msg.getbyte(0) == @uid and msg[-2,2].unpack('n')[0] == crc16(msg[0..-3])
          pdu = yield msg
          send_rtu_pdu(pdu)
		    end
        sleep(0.01)
	    end
    end

    # Calc CRC16 for message
    def crc16(msg)
      crc_lo = 0xff
      crc_hi = 0xff

      msg.unpack('c*').each do |byte|
        i = crc_hi ^ byte
        crc_hi = crc_lo ^ CrcHiTable[i]
        crc_lo = CrcLoTable[i]
      end

      return ((crc_hi << 8) + crc_lo)
    end

    CrcHiTable = [
        0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81,
        0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,
        0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01,
        0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
        0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81,
        0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,
        0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01,
        0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
        0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81,
        0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,
        0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01,
        0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
        0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81,
        0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,
        0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01,
        0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
        0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81,
        0x40]
    CrcLoTable = [
        0x00, 0xC0, 0xC1, 0x01, 0xC3, 0x03, 0x02, 0xC2, 0xC6, 0x06, 0x07, 0xC7, 0x05, 0xC5, 0xC4,
        0x04, 0xCC, 0x0C, 0x0D, 0xCD, 0x0F, 0xCF, 0xCE, 0x0E, 0x0A, 0xCA, 0xCB, 0x0B, 0xC9, 0x09,
        0x08, 0xC8, 0xD8, 0x18, 0x19, 0xD9, 0x1B, 0xDB, 0xDA, 0x1A, 0x1E, 0xDE, 0xDF, 0x1F, 0xDD,
        0x1D, 0x1C, 0xDC, 0x14, 0xD4, 0xD5, 0x15, 0xD7, 0x17, 0x16, 0xD6, 0xD2, 0x12, 0x13, 0xD3,
        0x11, 0xD1, 0xD0, 0x10, 0xF0, 0x30, 0x31, 0xF1, 0x33, 0xF3, 0xF2, 0x32, 0x36, 0xF6, 0xF7,
        0x37, 0xF5, 0x35, 0x34, 0xF4, 0x3C, 0xFC, 0xFD, 0x3D, 0xFF, 0x3F, 0x3E, 0xFE, 0xFA, 0x3A,
        0x3B, 0xFB, 0x39, 0xF9, 0xF8, 0x38, 0x28, 0xE8, 0xE9, 0x29, 0xEB, 0x2B, 0x2A, 0xEA, 0xEE,
        0x2E, 0x2F, 0xEF, 0x2D, 0xED, 0xEC, 0x2C, 0xE4, 0x24, 0x25, 0xE5, 0x27, 0xE7, 0xE6, 0x26,
        0x22, 0xE2, 0xE3, 0x23, 0xE1, 0x21, 0x20, 0xE0, 0xA0, 0x60, 0x61, 0xA1, 0x63, 0xA3, 0xA2,
        0x62, 0x66, 0xA6, 0xA7, 0x67, 0xA5, 0x65, 0x64, 0xA4, 0x6C, 0xAC, 0xAD, 0x6D, 0xAF, 0x6F,
        0x6E, 0xAE, 0xAA, 0x6A, 0x6B, 0xAB, 0x69, 0xA9, 0xA8, 0x68, 0x78, 0xB8, 0xB9, 0x79, 0xBB,
        0x7B, 0x7A, 0xBA, 0xBE, 0x7E, 0x7F, 0xBF, 0x7D, 0xBD, 0xBC, 0x7C, 0xB4, 0x74, 0x75, 0xB5,
        0x77, 0xB7, 0xB6, 0x76, 0x72, 0xB2, 0xB3, 0x73, 0xB1, 0x71, 0x70, 0xB0, 0x50, 0x90, 0x91,
        0x51, 0x93, 0x53, 0x52, 0x92, 0x96, 0x56, 0x57, 0x97, 0x55, 0x95, 0x94, 0x54, 0x9C, 0x5C,
        0x5D, 0x9D, 0x5F, 0x9F, 0x9E, 0x5E, 0x5A, 0x9A, 0x9B, 0x5B, 0x99, 0x59, 0x58, 0x98, 0x88,
        0x48, 0x49, 0x89, 0x4B, 0x8B, 0x8A, 0x4A, 0x4E, 0x8E, 0x8F, 0x4F, 0x8D, 0x4D, 0x4C, 0x8C,
        0x44, 0x84, 0x85, 0x45, 0x87, 0x47, 0x46, 0x86, 0x82, 0x42, 0x43, 0x83, 0x41, 0x81, 0x80,
        0x40]
        
    public 
    
    #enables us to do CRC calcs out of IRB for testing purposes
    def RTU.crc16(msg)
      crc_lo = 0xff
      crc_hi = 0xff

      msg.unpack('c*').each do |byte|
        i = crc_hi ^ byte
        crc_hi = crc_lo ^ CrcHiTable[i]
        crc_lo = CrcLoTable[i]
      end

      return ((crc_hi << 8) + crc_lo)
    end

  end
end


