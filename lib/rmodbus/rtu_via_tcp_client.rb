# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2009-2011  Timin Aleksey
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
module ModBus
  class RTUViaTCPClient < Client
		include RTU 
		include TCP

    protected
		# Connect with a ModBus server
		#
		# ipaddr - ip of the server
		#
		# port - port TCP connections
    def open_connection(ipaddr, port = 10002, opts = {})       
      io = open_tcp_connection(ipaddr, port, opts)
		end
    
    def get_slave(uid, io)
      RTUViaTCPSlave.new(uid, io)
    end
	end
end
