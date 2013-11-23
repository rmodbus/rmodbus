# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2011  Timin Aleksey
# Copyright (C) 2011  Steve Gooberman-Hill for multithread safety
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
  # TCP slave implementation
  # @example
  #   TCP.connect('127.0.0.1', 10002) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see RTUViaTCPClient#open_connection
  # @see Client#with_slave
  # @see Slave
  class TCPSlave < Slave
    include TCP
    attr_reader :transaction
    
    READ_TIMEOUT=0.1
    THREAD_SLEEP=0.01
         

    # @see Slave::initialize
    def initialize(uid, io, lock)
      @transaction = 0
      super(uid, io, lock)
    end

    private
    # overide method for RTU over TCP implementaion
    # @see Slave#query
    def send_pdu(pdu)
      @transaction = 0 if @transaction.next > 65535
      @transaction += 1
      msg = @transaction.to_word + "\0\0" + (pdu.size + 1).to_word + @uid.chr + pdu
      length=0
      
      begin
        @io.flush
        raise ModBus::Errors::ModBusTimeout, 'Device not ready' unless write_ready?(READ_TIMEOUT)      
        length=@io.syswrite(msg)
                  
      rescue SystemCallError => er
        log "TX: error #{er.to_s}"
      end
      raise ModBus::Errors::ProtocolError, "Incomplete Message sent #{length} of #{msg.bytesize}" unless length==msg.bytesize
      

      log "Tx (#{msg.bytesize} bytes): " + logging_bytes(msg)
    end

    # overide method for RTU over TCP implamentaion
    # @see Slave#query
    def read_pdu
      #ensure sockt is nonblocking
      msg=''
       
      begin
        @io.fcntl(Fcntl::F_SETFL, @io.fcntl(Fcntl::F_GETFL) | Fcntl::O_NONBLOCK)
        raise ModBus::Errors::ModBusTimeout, 'Device does not respond' unless read_ready?(READ_TIMEOUT)
        sleep(THREAD_SLEEP)
       
        #read up to and including the @uid
        #(uid is not returned as part of the message by the read_pdu message
        header = ''    
        begin
          #check again that there is data to read
          while header.bytesize < 7 && read_ready?(READ_TIMEOUT)
            header+=@io.sysread(7-header.bytesize)
         end
                 
        rescue SystemCallError, Errno::EAGAIN, EOFError => er
          $log.debug 'Rx :'+logging_bytes(header)
          $log.debug 'Rx : read error ' + er.to_s
          #next line will catch
        end
        raise ModBus::Errors::ProtocolError, "Incomplete ModbusTCP header read" unless header && header.bytesize==7
        
        tin = header[0,2].unpack('n')[0]
          
        raise Errors::ModBusException.new("Transaction number mismatch") unless tin == @transaction
        #data length includes the uid, so remove it as we read it in the header
        len = header[4,2].unpack('n')[0]-1
        msg=''    
        begin
          #check again that there is data to read
          while msg.bytesize < len && read_ready?(READ_TIMEOUT)
            msg+=@io.sysread(len-msg.bytesize)
          end
                 
        rescue SystemCallError, Errno::EAGAIN, EOFError => er
          $log.debug 'Rx :'+logging_bytes(msg)
          $log.debug 'Rx : read error ' + er.to_s
          #next line will catch
        end
        raise ModBus::Errors::ProtocolError, "Incomplete ModbusTCP message read" unless msg && msg.bytesize==len
        
        log "Rx (#{(header + msg).bytesize} bytes): " + logging_bytes(header + msg)
        msg
      rescue Exception, ModBus::Errors::ModBusException =>er
        log er.inspect #+er.backtrace[0..2].join(',')
        raise er if er.kind_of? ModBus::Errors::ModBusTimeout
      ensure
        msg ||=''
        #log "Rx Message : " + logging_bytes(msg)
        msg
      end
    end
    
  end
end
