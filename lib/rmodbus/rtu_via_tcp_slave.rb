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
  # RTU over TCP slave implementation
  # @example
  #   RTUViaTCP.connect('127.0.0.1', 10002) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see RTUViaTCPClient#open_connection
  # @see Client#with_slave
  # @see Slave
  class RTUViaTCPSlave < Slave
		include RTU

		protected
    # overide method for RTU over TCP implamentaion
    # @see Slave#query
		def send_pdu(pdu)
			msg = @uid.chr + pdu
			msg << crc16(msg).to_word
			@io.write msg

			log "Tx (#{msg.size} bytes): " + logging_bytes(msg)
		end

    # overide method for RTU over TCP implamentaion
    # @see Slave#query
		def read_pdu
			# Read the response appropriately
			msg = read_rtu_response(@io)

			log "Rx (#{msg.size} bytes): " + logging_bytes(msg)
			if msg.getbyte(0) == @uid
				return msg[1..-3] if msg[-2,2].unpack('n')[0] == crc16(msg[0..-3])
				log "Ignore package: don't match CRC"
			else
				log "Ignore package: don't match uid ID"
			end
			loop do
				#waite timeout
			end
		end
	end
end
