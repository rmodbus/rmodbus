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

module ModBus
  class Point
    attr_reader :name, :parent
    def initialize(name, parent = nil)
      @name = name
	  @parent = parent
	end
  end

  class Group
    attr_reader :name, :parent
    def initialize(name, parent = nil)
      @name = name
      @childrens = {} 
      @points = {} 
	  @parent = parent
	end

	def add_group(name, options={})
      @childrens.merge! name => Group.new(name, self) 
	end

	def add_point(name, options={})
      @points.merge! name => Point.new(name, self) 
	end

	def method_missing(name, *args)
	  result = @childrens[name.to_s]
	  if result.nil?
	    result = @points[name.to_s]
	  end
	  result
	end
  end

  class ProcessImage < Group
	def initialize(name, channel)
	  super(name)
	  @channel = channel
	  yield self
	end

	def add_scanner(name, options={})
	end
  end
end
