# RModBus - free implementation of ModBus protocol on Ruby.
# Copyright (C) 2010  Timin Aleksey
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

require "rmodbus/process/object"

module ModBus
  module Process
    class Point < ModBus::Process::Object
      attr_accessor :parent
      def initialize(name, parent = nil)
		super(name)
	    @parent = parent
	  end
    end
  end
end
