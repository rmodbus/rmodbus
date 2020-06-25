require 'digest/crc16_modbus'
require 'io/wait'

module ModBus
  module RTU
    private

    # We have to read specific amounts of numbers of bytes from the network depending on the function code and content
    def read_rtu_response(io)
	    # Read the slave_id and function code
      msg = read(io, 2)
      log logging_bytes(msg)

      function_code = msg.getbyte(1)
      case function_code
        when 1,2,3,4 then
          # read the third byte to find out how much more
          # we need to read + CRC
          msg += read(io, 1)
          msg += read(io, msg.getbyte(2)+2)
        when 5,6,15,16 then
          # We just read in an additional 6 bytes
          msg += read(io, 6)
        when 22 then
          msg += read(io, 8)
        when 0x80..0xff then
          msg += read(io, 3)
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

    def read(io, len)
      result = ""
      loop do
        this_iter = io.read(len - result.length)
        result.concat(this_iter) if this_iter
        return result if result.length == len
        io.wait_readable
      end
    end

    def read_rtu_request(io)
			# Every message is a minimum of 4 bytes (slave id, function code, crc16)
			msg = read(io, 4)

			# If msg is nil, then our client never sent us anything and it's time to disconnect
			return if msg.nil?

      loop do
        offset = 0
        crc = msg[-2..-1].unpack("S<").first

        # scan the bytestream for a valid CRC
        loop do
          break if offset >= msg.length - 3
          calculated_crc = Digest::CRC16Modbus.checksum(msg[offset..-3])
          if crc == calculated_crc
            is_response = (msg.getbyte(offset + 1) & 0x80 == 0x80) ||
              (msg.getbyte(offset) == @last_req_uid &&
                  msg.getbyte(offset + 1) == @last_req_func &&
              @last_req_timestamp && Time.now.to_f - @last_req_timestamp < 5)

            params = is_response ? parse_response(msg.getbyte(offset + 1), msg[(offset + 1)..-3]) :
                parse_request(msg.getbyte(offset + 1), msg[(offset + 1)..-3])

            unless params.nil?
              if is_response
                @last_req_uid = @last_req_func = @last_req_timestamp = nil
              else
                @last_req_uid = msg.getbyte(offset)
                @last_req_func = msg.getbyte(offset + 1)
                @last_req_timestamp = Time.now.to_f
              end
              log "Server RX discarding #{offset} bytes: #{logging_bytes(msg[0...offset])}" if offset != 0
              log "Server RX (#{msg.size - offset} bytes): #{logging_bytes(msg[offset..-1])}"
              return [msg.getbyte(offset), msg.getbyte(offset + 1), params, msg[offset + 1..-3], is_response]
            end
          end
          offset += 1
        end

        msg.concat(read(io, 1))
        # maximum message size is 256, so that's as far as we have to
        # be able to see at once
        msg = msg[1..-1] if msg.length > 256
      end
		end

    def serve(io)
      loop do
        # read the RTU message
        uid, func, params, pdu, is_response = read_rtu_request(io)

        next if uid.nil?

        pdu = exec_req(uid, func, params, pdu, is_response: is_response)
        next unless pdu

        @last_req_uid = @last_req_func = @last_req_timestamp = nil
        resp = uid.chr + pdu
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
