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

    @@transaction = 0

    # Connect with a ModBus server
    def initialize(ipaddr, port = 502, slaveaddr = 1)
      @ipaddr, @port = ipaddr, port
      tried = 0
      begin
        timeout(1, ModBusTimeout) do
        @sock = TCPSocket.new(@ipaddr, @port)
      end
      rescue ModBusTimeout => err
        tried += 1
        retry unless tried >= CONNECTION_RETRIES
        raise ModBusTimeout.new, 'Timed out attempting to create connection'
      end
      @slave = slaveaddr
    end

    def close
      @sock.close unless @sock.closed?
    end

    def self.transaction 
      @@transaction
    end

    private
    def send_pdu(pdu)   
      @@transaction += 1 
      @sock.write @@transaction.to_bytes + "\0\0" + (pdu.size + 1).to_bytes + @slave.chr + pdu
    end

    def read_pdu    
      header = @sock.read(7)            
      if header
        tin = header[0,2].to_int16
        raise Errors::ModBusException.new("Transaction number mismatch") unless tin == @@transaction
        len = header[4,2].to_int16       
        @sock.read(len-1)               
      else
        raise Errors::ModBusException.new("Server did not respond")
      end
    end

  end

end
