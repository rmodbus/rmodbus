# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2008  Timin Aleksey
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
require 'socket'
require 'timeout'
require 'rmodbus/client'
require 'rmodbus/exceptions'

module ModBus

  # Implementation clients(master) ModBusTCP
  class TCPClient < Client

    include Timeout

    attr_reader :ipaddr, :port, :slave
    attr_accessor :debug

    @@transaction = 0
    
    # Connect with ModBus server
    #
    # ipaddr - ip of the server
    #
    # port - port TCP connections
    #
    # slaveaddr - slave ID of the server
    #
    # TCPClient.connect('127.0.0.1') do |cl|
    #
    #   put cl.read_holding_registers(0, 10)
    #
    # end
    def self.connect(ipaddr, port = 502, slaveaddr = 1)
      cl = TCPClient.new(ipaddr, port, slaveaddr) 
      yield cl
      cl.close
    end

    # Connect with a ModBus server
    #
    # ipaddr - ip of the server
    #
    # port - port TCP connections
    #
    # slaveaddr - slave ID of the server
    def initialize(ipaddr, port = 502, slaveaddr = 1)
      @ipaddr, @port = ipaddr, port
      tried = 0
      begin
        timeout(1, ModBusTimeout) do
          @sock = TCPSocket.new(@ipaddr, @port)
        end
      rescue ModBusTimeout => err
        raise ModBusTimeout.new, 'Timed out attempting to create connection'
      end
      @slave = slaveaddr
      @debug = false
      super()
    end

    # Close TCP connections
    def close
      @sock.close unless @sock.closed?
    end

    # Check TCP connections
    def closed?
      @sock.closed?
    end

    def self.transaction 
      @@transaction
    end

    private
    def send_pdu(pdu)   
      @@transaction = 0 if @@transaction.next > 65535
      @@transaction += 1 
      msg = @@transaction.to_word + "\0\0" + (pdu.size + 1).to_word + @slave.chr + pdu
      @sock.write msg
      
      log "Tx (#{msg.size} bytes): " + logging_bytes(msg) + "\n"
    end

    def read_pdu    
      header = @sock.read(7)            
      if header
        tin = header[0,2].unpack('n')[0]
        raise Errors::ModBusException.new("Transaction number mismatch") unless tin == @@transaction
        len = header[4,2].unpack('n')[0]       
        msg = @sock.read(len-1)               

        log "Rx (#{(header + msg).size} bytes): " + logging_bytes(header + msg) + "\n"
        msg
      else
        raise Errors::ModBusException.new("Server did not respond")
      end
    end

  end

end
