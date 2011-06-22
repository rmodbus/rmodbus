# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2008-2011  Timin Aleksey
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
  class Client
    include Errors
        
    def initialize(*args, &blk)
      open_connection(*args)
      
      if blk
        yield self
        close
      else
        self
      end
    end
    
    class << self
      alias_method :connect, :new
    end
    
    def with_slave(uid, &blk)
      slave = get_slave(uid)
      if blk
        yield slave 
      else
        slave
      end
    end
    
    def closed? 
    end
    
    def close 
    end
    
    protected
    def open_connection(*args)    
    end
    
    def get_slave(uid)
      Slave.new(uid)
    end
  end
end
