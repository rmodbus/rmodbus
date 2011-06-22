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
      @io = open_connection(*args)
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
      slave = get_slave(uid, @io)
      if blk
        yield slave 
      else
        slave
      end
    end
    
    # Check connections
    def closed? 
      @io.closed?
    end
    
    # Close connections
    def close
      @io.close unless @io.closed?
    end
    
    protected
    def open_connection(*args)  
      #Stub conn object
      @io = Object.new
      def @io.close
      end
      def @io.closed?
        true
      end
      
      @io
    end
    
    def get_slave(uid,io)
      Slave.new(uid, io)
    end
  end
end
