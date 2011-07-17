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
require 'rmodbus/errors'
require 'rmodbus/ext'
require 'rmodbus/common'
require 'rmodbus/rtu'
require 'rmodbus/tcp'
require 'rmodbus/slave'
require 'rmodbus/client'
require 'rmodbus/server'
require 'rmodbus/tcp_slave'
require 'rmodbus/tcp_client'
require 'rmodbus/tcp_server'

# jruby not support serial RTU protocol yet
unless RUBY_PLATFORM == "java"
  require 'rmodbus/sp'
  require 'rmodbus/rtu_slave'
  require 'rmodbus/rtu_client'
  require 'rmodbus/rtu_server'
end

require 'rmodbus/rtu_via_tcp_slave'
require 'rmodbus/rtu_via_tcp_client'
require 'rmodbus/rtu_via_tcp_server'
require 'rmodbus/proxy'
require 'rmodbus/version'
