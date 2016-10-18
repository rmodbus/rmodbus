# RModBus - free implementation of ModBus protocol on Ruby.
# Copyright (C) 2008 - 2011 Timin Aleksey
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

require 'rmodbus/ext'
require 'rmodbus/proxy'
require 'rmodbus/version'

module ModBus
  autoload :Errors, 'rmodbus/errors'
  autoload :Debug, 'rmodbus/debug'
  autoload :Options, 'rmodbus/options'
  autoload :SP, 'rmodbus/sp'
  autoload :RTU, 'rmodbus/rtu'
  autoload :TCP, 'rmodbus/tcp'
  autoload :Slave, 'rmodbus/slave'
  autoload :Client, 'rmodbus/client'
  autoload :Server, 'rmodbus/server'
  autoload :TCPSlave, 'rmodbus/tcp_slave'
  autoload :TCPClient, 'rmodbus/tcp_client'
  autoload :TCPServer, 'rmodbus/tcp_server'
  autoload :RTUSlave, 'rmodbus/rtu_slave'
  autoload :RTUClient, 'rmodbus/rtu_client'
  autoload :RTUServer, 'rmodbus/rtu_server'
  autoload :RTUViaTCPSlave, 'rmodbus/rtu_via_tcp_slave'
  autoload :RTUViaTCPClient, 'rmodbus/rtu_via_tcp_client'
  autoload :RTUViaTCPServer, 'rmodbus/rtu_via_tcp_server'
end
