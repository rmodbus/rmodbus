# RModBus - free implementation of ModBus protocol in Ruby.
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
  # RTU slave implementation
  # @example
  #   RTUClient.connect(port, baud, opts) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see RTUClient#open_connection
  # @see Client#with_slave
  # @see Slave
  class RTUSlave < Slave
    include RTU
    
    def renew_connection
      port=@io.port
      baud=@io.baud
      @query_lock.synchronize do
        @io.close
        @io=open_serial_port(port,baud)
        clear_buffer
      end
    end


    private
    # overide method for RTU implamentaion
    # @see Slave#query
    def send_pdu(pdu)
      send_rtu_pdu(pdu)
    end

    # overide method for RTU implamentaion
    # @see Slave#query
    def read_pdu
      read_rtu_pdu
    end
  end
end
