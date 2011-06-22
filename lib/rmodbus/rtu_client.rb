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

    protected
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
    def open_connection(port, baud=9600, opts = {})
      open_serial_port(port, baud, opts)
    end
    
    def get_slave(uid, io)
      RTUSlave.new(uid, io)
    end
  end
end
