# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2010  Timin Aleksey
# Copyright (C) 2010  Kelley Reynolds
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

require 'rmodbus/parsers'
require 'gserver'

module ModBus
 
	class RTUViaTCPServer < GServer
		include Parsers
		include CRC16
		include Common
		
		attr_accessor :coils, :discrete_inputs, :holding_registers, :input_registers, :debug

		def initialize(port = 10002, slave = 1)
			@coils = []
			@discrete_inputs = []
			@holding_registers =[]
			@input_registers = []
			@slave = slave
			super(port)
		end

		def serve(io)
			loop do
				# read the RTU message
				msg = read_modbus_rtu_request(io)
				
				# If there is no RTU message, we're done serving this client
				break if msg.nil?
				
				if msg.getbyte(0) == @slave and msg[-2,2].unpack('n')[0] == crc16(msg[0..-3])
					pdu = exec_req(msg[1..-3], @coils, @discrete_inputs, @holding_registers, @input_registers)
					resp = @slave.chr + pdu
					resp << crc16(resp).to_word
					log "Server TX (#{resp.size} bytes): #{logging_bytes(resp)}"
					io.write resp
				end
			end
		end
		
		private
		
		# We have to read specific amounts of numbers of bytes from the network depending on the function code and content
		# NOTE: The initial read could be increased to 7 and that would let us cobine the two reads for functions 15 and 16 but this method is more clear
		def read_modbus_rtu_request(io)
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
		
		def log(msg)
			if @debug
				$stdout.puts msg
			end
		end

		def logging_bytes(msg)
			result = ""
			msg.each_byte do |c|
				byte = if c < 16
					'0' + c.to_s(16)
				else
					c.to_s(16)
				end
				result << "[#{byte}]"
			end
			result
		end
	end
end
