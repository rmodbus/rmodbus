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

require 'gserver'

module ModBus
  # RTU over TCP server implementation
  # @example
  #   srv = RTUViaTCPServer.new(10002, 1)
  #   srv.coils = [1,0,1,1]
  #   srv.discrete_inputs = [1,1,0,0]
  #   srv.holding_registers = [1,2,3,4]
  #   srv.input_registers = [1,2,3,4]
  #   srv.debug = true
  #   srv.start
  class RTUViaTCPServer < GServer
    include Common
    include RTU
    include Server

    # Init server
    # @params [Integer] port listen port
    # @param [Integer] uid slave device
    def initialize(port = 10002, uid = 1)
      @uid = uid
      super(port)
    end

    protected
    # Serve requests
    # @param [TCPSocket] io socket
    def serve(io)
      serv_rtu_requests(io) do |msg|
        exec_req(msg[1..-3], @coils, @discrete_inputs, @holding_registers, @input_registers)
      end
    end
  end
end
