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
require 'serialport'

module ModBus
  class RTUServer
    include Common 
    include Server 
    include RTU 

    attr_reader :port, :baud, :data_bits, :stop_bits, :parity

    def initialize(port, baud=9600, uid=1, opts = {})
      Thread.abort_on_exception = true 
      @sp = open_serial_port(port, baud, opts)
      @uid = uid
    end

    def start
      @serv = Thread.new do
        serv_rtu_requests(@sp) do |msg|
          exec_req(msg[1..-3], @coils, @discrete_inputs, @holding_registers, @input_registers)
        end
      end
    end

    def stop
      Thread.kill(@serv)
      @sp.close 
    end

    def join
      @serv.join
    end
  end
end
