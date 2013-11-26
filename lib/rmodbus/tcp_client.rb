# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2008-2011  Timin Aleksey
# Copyright (C) 2011  Steve Gooberman-Hill for multithread safety
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
  # TCP client implementation
  # @example
  #   TCPClient.connect('127.0.0.1', 502) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see TCP#open_tcp_connection
  # @see Client#initialize
  class TCPClient < Client
    include TCP

    protected
    # Open TCP\IP connection
    def open_connection(ipaddr, port = 502, opts = {})
      open_tcp_connection(ipaddr, port, opts)
    end

    def get_slave(uid, io)
      TCPSlave.new(uid, io, @query_lock)
    end
  end
end
