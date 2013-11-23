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
    include Errors
    include Timeout
    attr_reader :ipaddr, :port
    # Open TCP socket
    #
    # @param [String] ipaddr IP address of remote server
    # @param [Integer] port connection port
    # @param [Hash] opts options of connection
    # @option opts [Float, Integer] :connect_timeout seconds timeout for open socket
    # @return [TCPSocket] socket
    #
    # @raise [ModBusTimeout] timed out attempting to create connection
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

    #stub - not really required for ModbusTCP as we are using transaction numbers
    def clear_buffer
       #nothing to do here
    end

  end
end
