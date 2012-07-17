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

module ModBus
  module SP
    attr_reader :port, :baud, :data_bits, :stop_bits, :parity, :read_timeout
    # Open serial port
    # @param [String] port name serial ports ("/dev/ttyS0" POSIX, "com1" - Windows)
    # @param [Integer] baud rate serial port (default 9600)
    # @param [Hash] opts the options of serial port
    #
    # @option opts [Integer] :data_bits from 5 to 8
    # @option opts [Integer] :stop_bits 1 or 2
    # @option opts [Integer] :parity NONE, EVEN or ODD
    # @option opts [Integer] :read_timeout default 100 ms
    # @return [SerialPort] io serial port
    def open_serial_port(port, baud, opts = {})
      @port, @baud = port, baud

      @data_bits, @stop_bits, @parity, @read_timeout = 8, 1, SerialPort::NONE, 100

      @data_bits = opts[:data_bits] unless opts[:data_bits].nil?
      @stop_bits = opts[:stop_bits] unless opts[:stop_bits].nil?
      @parity = opts[:parity] unless opts[:parity].nil?
      @read_timeout = opts[:read_timeout] unless opts[:read_timeout].nil?

      io = SerialPort.new(@port, @baud, @data_bits, @stop_bits, @parity)
      io.flow_control = SerialPort::NONE
      io.read_timeout = @read_timeout
      io
    end
  end
end

