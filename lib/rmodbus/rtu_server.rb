# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2010-2011 Timin Aleksey
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
#
module ModBus
  # RTU server implementation
  # @example
  #   srv = RTUServer.new('/dev/ttyS1', 9600, 1)
  #   srv.coils = [1,0,1,1]
  #   srv.discrete_inputs = [1,1,0,0]
  #   srv.holding_registers = [1,2,3,4]
  #   srv.input_registers = [1,2,3,4]
  #   srv.debug = true
  #   srv.start
  class RTUServer
    include Common
    include Server
    include RTU
    include SP

    # Init RTU server
    # @param [Integer] uid slave device
    # @see SP#open_serial_port
    def initialize(port, baud=9600, uid=1, opts = {})
      Thread.abort_on_exception = true
      @sp = open_serial_port(port, baud, opts)
      @uid = uid
    end

    # Start server
    def start
      @serv = Thread.new do
        serv_rtu_requests(@sp) do |msg|
          exec_req(msg[1..-3], @coils, @discrete_inputs, @holding_registers, @input_registers)
        end
      end
    end

    # Stop server
    def stop
      Thread.kill(@serv)
      @sp.close
    end

    # Join server
    def join
      @serv.join
    end
  end
end
