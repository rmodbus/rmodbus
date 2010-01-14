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

require 'rmodbus/parsers'

begin
  require 'rubygems'
rescue
end

require 'serialport'

module ModBus
 
  class RTUServer
    include Parsers
    include CRC16

    attr_accessor :coils, :discret_inputs, :holding_registers, :input_registers

    def initialize(port, baud=9600, slaveaddr=1)
      @sp = SerialPort.new(port, baud, slaveaddr)
      @sp.read_timeout = 5

      @coils = []
      @discret_inputs = []
      @holding_registers = []
      @input_registers = []
      @slave = slaveaddr
    end

    def start
      @serv = Thread.new do
        loop do
          req = '' 
          while req.size == 0 
            req = @sp.read
          end
       
          if req.getbyte(0) == @slave and req[-2,2] == crc16(req[0..-3]).to_word
            params = exec_req(req, @coils, @discret_inputs, @holding_registers, @input_registers)

            if params[:err] ==  0
              resp = @slave.sgr + params[:res]
            else
              resp =  @uid.chr + (params[:func] | 0x80).chr + params[:err].chr
            end 
            @sp.write resp + crc16(resp)
          end
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

