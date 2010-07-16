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
    class Group < ModBus::Process::Object
      attr_accessor :parent
      def initialize(name, parent = nil)
		super(name)
        @childrens = {} 
	    @parent = parent
	  end

	  def add(obj)
	    obj.parent = self
        @childrens.merge! obj.id => obj
	  end

	  def method_missing(name, *args)
	    @childrens.values.find { |obj| obj.name == name.to_s } 
	  end
	end
  end
end
