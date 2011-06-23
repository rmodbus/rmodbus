# RModBus - free implementation of ModBus protocol on Ruby.
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
  # TCP slave implementation
  # @example
  #   TCP.connect('127.0.0.1', 10002) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see RTUViaTCPClient#open_connection
  # @see Client#with_slave
  # @see Slave
  class TCPSlave < Slave
    attr_reader :transaction

    # @see Slave::initialize
    def initialize(uid, io)
      @transaction = 0
      super(uid, io)
    end

    private
    # overide method for RTU over TCP implamentaion
    # @see Slave#query
    def send_pdu(pdu)
      @transaction = 0 if @transaction.next > 65535
      @transaction += 1
      msg = @transaction.to_word + "\0\0" + (pdu.size + 1).to_word + @uid.chr + pdu
      @io.write msg

      log "Tx (#{msg.size} bytes): " + logging_bytes(msg)
    end

    # overide method for RTU over TCP implamentaion
    # @see Slave#query
    def read_pdu
      header = @io.read(7)
      if header
        tin = header[0,2].unpack('n')[0]
        raise Errors::ModBusException.new("Transaction number mismatch") unless tin == @transaction
        len = header[4,2].unpack('n')[0]
        msg = @io.read(len-1)

        log "Rx (#{(header + msg).size} bytes): " + logging_bytes(header + msg)
        msg
      else
        raise Errors::ModBusException.new("Server did not respond")
      end
    end
  end
end
