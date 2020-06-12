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

    def read_rtu_request(io)
			# Every message is a minimum of 5 bytes (slave id, function code, error code, crc16)
			msg = io.read(5)

			# If msg is nil, then our client never sent us anything and it's time to disconnect
			return if msg.nil?

      loop do
        offset = 0
        crc = msg[-2..-1].unpack("S<").first
        # scan the bytestream for a valid CRC
        loop do
          break if offset == msg.length - 3
          calculated_crc = Digest::CRC16Modbus.checksum(msg[offset..-3])
          return msg[offset..-1] if crc == calculated_crc
          offset += 1
        end

        msg << io.readbyte
        # maximum message size is 256, so that's as far as we have to
        # be able to see at once
        msg = msg[1..-1] if msg.length > 256
      end

			log "Server RX (#{msg.size} bytes): #{logging_bytes(msg)}"

			msg
		end

    def serve(io)
      loop do
        # read the RTU message
        msg = read_rtu_request(io)

        next if msg.nil?

        log "Server RX (#{msg.size} bytes): #{logging_bytes(msg)}"

        pdu = exec_req(msg[1..-3], msg.getbyte(0))
        next unless pdu

        resp = msg.getbyte(0).chr + pdu
        resp << [crc16(resp)].pack("S<")
        log "Server TX (#{resp.size} bytes): #{logging_bytes(resp)}"
        io.write resp
      end
    end

    # Calc CRC16 for massage
    def crc16(msg)
      Digest::CRC16Modbus.checksum(msg)
    end
  end
end
