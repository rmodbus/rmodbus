# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2008-2011  Timin Aleksey
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
require 'gserver'

module ModBus
  # TCP server implementation
  # @example
  #   srv = TCPServer.new(10002, 1)
  #   srv.coils = [1,0,1,1]
  #   srv.discrete_inputs = [1,1,0,0]
  #   srv.holding_registers = [1,2,3,4]
  #   srv.input_registers = [1,2,3,4]
  #   srv.debug = true
  #   srv.start
	class TCPServer < GServer
		include Debug
		include Server 
    
    # Init server
    # @param [Integer] port listen port
    # @param [Integer] uid slave device
    # @param [Hash] opts options of server
    # @option opts [String] :host host of server default '127.0.0.1'
    # @option opts [Float, Integer] :max_connection max of TCP connection with server default 4
		def initialize(port = 502, uid = 1, opts = {})
			@uid = uid
      opts[:host] = DEFAULT_HOST unless opts[:host]
      opts[:max_connection] = 4 unless opts[:max_connection]
			super(port, host = opts[:host], maxConnection = opts[:max_connection])
		end

    # Serve requests
    # @param [TCPSocket] io socket
		def serve(io)
			while not stopped? 
				req = io.read(7)
				if req[2,2] == "\x00\x00" or req.getbyte(6) == @uid
          tr = req[0,2]
          len = req[4,2].unpack('n')[0]
          req = io.read(len - 1)
          log "Server RX (#{req.size} bytes): #{logging_bytes(req)}"

          pdu = exec_req(req, @coils, @discrete_inputs, @holding_registers, @input_registers)

          resp = tr + "\0\0" + (pdu.size + 1).to_word + @uid.chr + pdu
          log "Server TX (#{resp.size} bytes): #{logging_bytes(resp)}"
          io.write resp
        end
        sleep(0.01)
			end
		end
	end
end
