# RModBus - free implementation of ModBus protocol on Ruby.
# Copyright (C) 2008  Timin Aleksey
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
require 'rmodbus/adu'

module ModBus

  # Implementation clients(master) ModBusTCP
  class TCPClient < Client

    include Timeout

    # Connect with a ModBus
    def initialize(ipaddr, port = 502, slaveaddr = 1)
      timeout(1) do
        @sock = TCPSocket.new(ipaddr, port)
      end
      @slave = slaveaddr
    end
 
    private
    def send_pdu(pdu)   
      @adu = ADU.new(pdu,@slave) 
      @sock.write @adu.serialize
    end

    def read_pdu     
      header = @sock.read(7)            
      tin = header[0,2].to_int16
      raise Errors::ModBusException.new("Transaction number mismatch") unless tin == @adu.transaction_id
      len = header[4,2].to_int16       
      @sock.read(len-1)               
    end

  end

end
