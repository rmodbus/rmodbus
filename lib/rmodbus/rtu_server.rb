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
require 'rmodbus/modicon'

begin
  require 'rubygems'
rescue
end

require 'serialport'

module ModBus
 
  class RTUServer
    include Parsers
    include CRC16
    include Modicon::Server

    attr_accessor :coils, :discrete_inputs, :holding_registers, :input_registers
    attr_reader :port, :baud, :slave, :data_bits, :stop_bits, :parity

     def discret_inputs
      warn "[DEPRECATION] `discret_inputs` is deprecated.  Please use `discrete_inputs` instead."
      @discrete_inputs 
    end
  
    def discret_inputs=(val)
      warn "[DEPRECATION] `discret_inputs=` is deprecated.  Please use `discrete_inputs=` instead."
      @discrete_inputs=val
    end


    def initialize(port, baud=9600, slaveaddr=1, options = {})
      Thread.abort_on_exception = true 

      @port, @baud = port, baud
      @data_bits, @stop_bits, @parity = 8, 1, SerialPort::NONE

      @data_bits = options[:data_bits] unless options[:data_bits].nil?
      @stop_bits = options[:stop_bits] unless options[:stop_bits].nil?
      @parity = options[:parity] unless options[:parity].nil?

      @sp = SerialPort.new(@port, @baud, @data_bits, @stop_bits, @parity)
      @sp.read_timeout = 5

      @coils = []
      @discrete_inputs = []
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
          if req.getbyte(0) == @slave and req[-2,2].unpack('n')[0] == crc16(req[0..-3])
            pdu = exec_req(req[1..-1], @coils, @discrete_inputs, @holding_registers, @input_registers)
            resp = @slave.chr + pdu
            resp << crc16(resp).to_word
            @sp.write resp
          end
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
