# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2009-2011  Timin Aleksey
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
  class RTUClient < Client
    include RTU
    include SP

    protected
    def open_connection(port, baud=9600, opts = {})
      open_serial_port(port, baud, opts)
    end

    def get_slave(uid, io)
      RTUSlave.new(uid, io)
    end
  end
end
