require 'digest/crc16_modbus'

module ModBus
  module RTU
    private

    # We have to read specific amounts of numbers of bytes from the network depending on the function code and content
    def read_rtu_response(io)
	    # Read the slave_id and function code
      msg = nil
      while msg.nil?
	      msg = io.read(2)
      end

      function_code = msg.getbyte(1)
      case function_code
        when 1,2,3,4 then
          # read the third byte to find out how much more
          # we need to read + CRC
          msg += io.read(1)
          msg += io.read(msg.getbyte(2)+2)
        when 5,6,15,16 then
          # We just read in an additional 6 bytes
          msg += io.read(6)
        when 22 then
          msg += io.read(8)
        when 0x80..0xff then
          msg += io.read(3)
        else
          raise ModBus::Errors::IllegalFunction, "Illegal function: #{function_code}"
      end
    end

    def clean_input_buff
      # empty the input buffer
      if @io.class.public_method_defined? :flush_input
        @io.flush_input
      else
        @io.flush
      end
    end

    def send_rtu_pdu(pdu)
      msg = @uid.chr + pdu
      msg << [crc16(msg)].pack("S<")

      clean_input_buff
      @io.write msg

      log "Tx (#{msg.size} bytes): " + logging_bytes(msg)
    end

    def read_rtu_pdu
      msg = read_rtu_response(@io)

      log "Rx (#{msg.size} bytes): " + logging_bytes(msg)

      if msg.getbyte(0) == @uid
        return msg[1..-3] if msg[-2,2].unpack('S<')[0] == crc16(msg[0..-3])
        log "Ignore package: don't match CRC"
      else
        log "Ignore package: don't match uid ID"
      end
      loop do
        #waite timeout
        sleep(0.1)
      end
    end

    def read_rtu_request(io)
			# Read the slave_id and function code
			msg = io.read(2)

			# If msg is nil, then our client never sent us anything and it's time to disconnect
			return if msg.nil?

			function_code = msg.getbyte(1)
			if [1, 2, 3, 4, 5, 6].include?(function_code)
				# read 6 more bytes and return the message total message
				msg += io.read(6)
			elsif [15, 16].include?(function_code)
				# Read in first register, register count, and data bytes
				msg += io.read(5)
				# Read in however much data we need to + 2 CRC bytes
				msg += io.read(msg.getbyte(6) + 2)
			else
				raise ModBus::Errors::IllegalFunction, "Illegal function: #{function_code}"
			end

			log "Server RX (#{msg.size} bytes): #{logging_bytes(msg)}"

			msg
		end

    def serv_rtu_requests(io)
      loop do
        # read the RTU message
        msg = read_rtu_request(io)

        next if msg.nil?

        if msg[-2,2].unpack('S<')[0] == crc16(msg[0..-3])
          pdu = yield msg
          next unless pdu
          resp = msg.getbyte(0).chr + pdu
          resp << [crc16(resp)].pack("S<")
          log "Server TX (#{resp.size} bytes): #{logging_bytes(resp)}"
          io.write resp
		    end
	    end
    end

    # Calc CRC16 for massage
    def crc16(msg)
      Digest::CRC16Modbus.checksum(msg)
    end
  end
end
