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
require 'socket'
require 'timeout'

module ModBus
  module TCP
    include Timeout
    attr_reader :ipaddr, :port
    
    private
    def open_tcp_connection(ipaddr, port, opts = {})
      @ipaddr, @port = ipaddr, port
      
      opts[:connect_timeout] ||= 1
      
      io = nil
      begin
        timeout(opts[:connect_timeout], ModBusTimeout) do
          io = TCPSocket.new(@ipaddr, @port)
        end
      rescue ModBusTimeout => err
        raise ModBusTimeout.new, 'Timed out attempting to create connection'
      end
      
      io
    end
  end  
end