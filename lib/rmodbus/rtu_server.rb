# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2010  Timin Aleksey
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

begin
  require 'rubygems'
rescue
end
require 'serialport'

module ModBus
 
  class RTUServer

    attr_accessor :coils, :discret_inputs, :holding_registers, :input_registers

    def initialize(port, baud=9600, slaveaddr=1)
      @sp = SerialPort.new(port, baud, slaveaddr)
      @sp.read_timeout = 5

      @coils = []
      @discret_inputs = []
      @holding_registers = []
      @input_registers = []
    end

    def start
      @serv = Thread.new do
        msg = '' 
        while msg.size == 0 
          msg = @sp.read
        end

        if msg.getbyte(0) == @slave
        end
      end
    end

    def stop
      @serv.stop
    end

    def join
      @serv.join
    end
  end

end

