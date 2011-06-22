# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2009-2011  Timin Aleksey
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
  class RTUClient < Client
    include RTU 
    attr_reader :port, :baud, :data_bits, :stop_bits, :parity, :read_timeout

    # Connect with RTU server
    #
    # port - serial port of connections with RTU server
    #
    # baud - rate sp of connections with RTU server
    #
    # Options:
    #
    # :data_bits => from 5 to 8
    #
    # :stop_bits => 1 or 2
    #
    # :parity => NONE, EVEN or ODD
    #
    def self.connect(port, baud=9600, options = {})
      cl = RTUClient.new(port, baud, options) 
      yield cl
      cl.close
    end

    # Connect with RTU server
    #
    # port - serial port of connections with RTU server
    #
    # baud - rate sp of connections with RTU server
    #
    # data_bits - from 5 to 8
    #
    # stop_bits - 1 or 2
    #
    # parity - NONE, EVEN or ODD
    #
    # Options:
    #
    # :data_bits => from 5 to 8
    #
    # :stop_bits => 1 or 2
    #
    # :parity => NONE, EVEN or ODD
    #
    # :read_timeout => default 5 ms
    def initialize(port, baud=9600, options = {})
      @port, @baud = port, baud
      
      @data_bits, @stop_bits, @parity, @read_timeout = 8, 1, SerialPort::NONE, 5

      @data_bits = options[:data_bits] unless options[:data_bits].nil?
      @stop_bits = options[:stop_bits] unless options[:stop_bits].nil?
      @parity = options[:parity] unless options[:parity].nil?
      @read_timeout = options[:read_timeout] unless options[:read_timeout].nil?

      @sp = SerialPort.new(@port, @baud, @data_bits, @stop_bits, @parity)
      @sp.read_timeout = @read_timeout
      super()
    end

    def with_slave(uid, &blk)
      slave = RTUSlave.new(uid, @sp)
      if blk
        yield slave 
      else
        slave
      end
    end

    def close
      @sp.close unless @sp.closed?
    end

    def closed?
      @sp.closed?
    end
  end
end
