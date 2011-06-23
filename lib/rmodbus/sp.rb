# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2011  Timin Aleksey
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
  module SP
      attr_reader :port, :baud, :data_bits, :stop_bits, :parity, :read_timeout
      # Open serial port
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
      def open_serial_port(port, baud, opts = {})
        @port, @baud = port, baud

        @data_bits, @stop_bits, @parity, @read_timeout = 8, 1, SerialPort::NONE, 5

        @data_bits = opts[:data_bits] unless opts[:data_bits].nil?
        @stop_bits = opts[:stop_bits] unless opts[:stop_bits].nil?
        @parity = opts[:parity] unless opts[:parity].nil?
        @read_timeout = options[:read_timeout] unless opts[:read_timeout].nil?

        io = SerialPort.new(@port, @baud, @data_bits, @stop_bits, @parity)
        io.read_timeout = @read_timeout
        io
      end
  end
end