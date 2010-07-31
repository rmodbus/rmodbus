# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2008  Timin Aleksey
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
	class TCPServer < GServer
		include Parsers
		include Common

		attr_accessor :coils, :discrete_inputs, :holding_registers, :input_registers, :debug

		def discret_inputs
			warn "[DEPRECATION] `discret_inputs` is deprecated.  Please use `discrete_inputs` instead."
			@discrete_inputs 
		end

		def discret_inputs=(val)
			warn "[DEPRECATION] `discret_inputs=` is deprecated.  Please use `discrete_inputs=` instead."
			@discrete_inputs=val
		end

		def initialize(port = 502, uid = 1)
			@coils = []
			@discrete_inputs = []
			@holding_registers =[]
			@input_registers = []
			@uid = uid
			super(port)
		end

		def serve(io)
			loop do
				req = io.read(7)
				if req[2,2] != "\x00\x00" or req.getbyte(6) != @uid
					io.close
					break
				end

				tr = req[0,2]
				len = req[4,2].unpack('n')[0]
				req = io.read(len - 1)
				log "Server RX (#{req.size} bytes): #{logging_bytes(req)}"

				pdu = exec_req(req, @coils, @discrete_inputs, @holding_registers, @input_registers)

				resp = tr + "\0\0" + (pdu.size + 1).to_word + @uid.chr + pdu
				log "Server TX (#{resp.size} bytes): #{logging_bytes(resp)}"
				io.write resp
			end
		end
	end
end
