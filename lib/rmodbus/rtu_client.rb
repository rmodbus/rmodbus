# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2009  Timin Aleksey
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
require 'rmodbus/crc16'

begin
  require 'rubygems'
rescue
end
require 'serialport'

module ModBus
  
  class RTUClient < Client

    include CRC16
    attr_reader :port, :baud, :slave
    attr_accessor :debug

    # Connect with RTU server
    #
    # port - serial port of connections with RTU server
    #
    # baud - rate sp of connections with RTU server
    #
    # slaveaddr - slave ID of the RTU server
    #
    # RTUClient.connect('/dev/port1') do |cl|
    #
    #   put cl.read_holding_registers(0, 10)
    #
    # end
    def self.connect(port, baud=9600, slaveaddr=1)
      cl = RTUClient.new(port, baud, slaveaddr) 
      yield cl
      cl.close
    end

    # Connect with RTU server
    #
    # port - serial port of connections with RTU server
    #
    # baud - rate sp of connections with RTU server
    #
    # slaveaddr - slave ID of the RTU server
    def initialize(port, baud=9600, slaveaddr=1)
      @port, @baud, @slave =port, baud, slaveaddr
      @debug = false

      @sp = SerialPort.new(port, baud)
      @sp.read_timeout = 5

      super()
    end

    def close
      @sp.close
    end

    protected
    def send_pdu(pdu)
      msg = @slave.chr + pdu 
      msg << crc16(msg).to_word
      @sp.write msg
      if @debug
        STDOUT << "Tx (#{msg.size} bytes): " + logging_bytes(msg) + "\n"
      end
    end

    def read_pdu
      msg = ''
      while msg.size == 0
        msg =  @sp.read
      end

      if @debug
        STDOUT << "Rx (#{msg.size} bytes): " + logging_bytes(msg) + "\n"
      end

      if msg.getbyte(0) == @slave
        return msg[1..-3] if msg[-2,2].unpack('n')[0] == crc16(msg[0..-3])
      end
      loop do
        #waite timeout  
      end
    end
  end
end
