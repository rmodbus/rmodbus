# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2009  Timin Aleksey
# Copyright (C) 2010  Kelley Reynolds
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
require 'timeout'
require 'rmodbus/client'
require 'rmodbus/exceptions'

module ModBus
  
	class RTUViaTCPClient < Client

		include CRC16
		attr_reader :ipaddr, :port, :slave
		attr_accessor :debug

		# Connect with Serial TCP Gateway (eg barionet-50)
		#
		# ipaddr - ip of the server
		#
		# port - port TCP connections
		#
		# slaveaddr - slave ID of the server
		#
		# RTUViaTCPClient.connect('127.0.0.1') do |cl|
		#
		#   put cl.read_holding_registers(0, 10)
		#
		# end
		def self.connect(ipaddr, port = 10002, slaveaddr = 1)
			cl = RTUViaTCPClient.new(ipaddr, port, slaveaddr) 
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
		def initialize(ipaddr, port = 10002, slaveaddr = 1)
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

		protected

		def send_pdu(pdu)
			msg = @slave.chr + pdu 
			msg << crc16(msg).to_word
			@sock.write msg

			log "Tx (#{msg.size} bytes): " + logging_bytes(msg)
		end

		def read_pdu
			# Read the response appropriately
			msg = read_modbus_rtu_response(@sock)

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
		
		# We have to read specific amounts of numbers of bytes from the network depending on the function code and content
		def read_modbus_rtu_response(io)
			# Read the slave_id and function code
			msg = io.read(2)
			function_code = msg.getbyte(1)
			if [1, 2, 3, 4].include?(function_code)
				# read the third byte to find out how much more we need to read + CRC
				msg += io.read(1)
				msg += io.read(msg.getbyte(2)+2)
			elsif [5, 6, 15, 16].include?(function_code)
				# We just read in an additional 6 bytes
				msg += io.read(6)
			else
				raise ModBus::Errors::IllegalFunction, "Illegal function: #{function_code}"
			end
			
			msg
		end
		
	end
end
