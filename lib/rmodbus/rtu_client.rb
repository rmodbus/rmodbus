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
    attr_reader :port, :baud, :slave, :data_bits, :stop_bits, :parity, :read_timeout
    attr_accessor :debug

    # Connect with RTU server
    #
    # port - serial port of connections with RTU server
    #
    # baud - rate sp of connections with RTU server
    #
    # slaveaddr - slave ID of the RTU server
    #
    # Options:
    #
    # :data_bits => from 5 to 8
    #
    # :stop_bits => 1 or 2
    #
    # :parity => NONE, EVEN or ODD
    #
    # RTUClient.connect('/dev/port1') do |cl|
    #
    #   put cl.read_holding_registers(0, 10)
    #
    # end
    def self.connect(port, baud=9600, slaveaddr=1, options = {})
      cl = RTUClient.new(port, baud, slaveaddr, options) 
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
    # slaveaddr - slave ID of the RTU server    # Connect with RTU server
    #
    # port - serial port of connections with RTU server
    #
    # baud - rate sp of connections with RTU server
    #
    # slaveaddr - slave ID of the RTU server
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
    def initialize(port, baud=9600, slaveaddr=1, options = {})
      @port, @baud, @slave = port, baud, slaveaddr
      
      @data_bits, @stop_bits, @parity, @read_timeout = 8, 1, SerialPort::NONE, 5

      @data_bits = options[:data_bits] unless options[:data_bits].nil?
      @stop_bits = options[:stop_bits] unless options[:stop_bits].nil?
      @parity = options[:parity] unless options[:parity].nil?
      @read_timeout = options[:read_timeout] unless options[:read_timeout].nil?

      @debug = false

      @sp = SerialPort.new(@port, @baud, @data_bits, @stop_bits, @parity)
      @sp.read_timeout = @read_timeout

      super()
    end

    def close
      @sp.close unless @sp.closed?
    end

    def closed?
      @sp.closed?
    end

    protected
    def send_pdu(pdu)
      msg = @slave.chr + pdu 
      msg << crc16(msg).to_word
      @sp.write msg

      log "Tx (#{msg.size} bytes): " + logging_bytes(msg)
    end

    def read_pdu
      msg = ''
      while msg.size == 0
        msg =  @sp.read
      end

      log "Rx (#{msg.size} bytes): " + logging_bytes(msg)

      if msg.getbyte(0) == @slave
        return msg[1..-3] if msg[-2,2].unpack('n')[0] == crc16(msg[0..-3])
        log "Ignore package: don't match CRC"
	  else 
        log "Ignore package: don't match slave ID"
      end
      loop do
        #waite timeout  
      end
    end
  end
end
