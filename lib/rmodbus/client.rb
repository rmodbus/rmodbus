# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2008-2011  Timin Aleksey
# Copyright (C) 2011  Steve Gooberman-Hill for multithread safety
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
  # @abstract
  class Client
    include Errors
    include Debug
    include Options
    
    attr_accessor :heartbeat

    # Initialized client (alias :connect)
    # @example
    #   Client.new(any_args) do |client|
    #     client.closed? #=> false
    #   end
    # @param *args depends on implementation
    # @yield return client object and close it before exit
    # @return [Client] client object
    def initialize(*args, &block)
      # Defaults 
      @debug = false
      @raise_exception_on_mismatch = false
      @read_retry_timeout = 2
      @read_retries = 20
      
      
      #client may be connected to more than one device, so we need to ensure that the
      #physical interface is only being accessed by a single Thread at a time 
      @query_lock=Mutex.new 
      #the heartbeat is set every time the query_lock is gained in a #synchronize block
      #this enables us to check whether the system is responding or is blocked
      #of course, it should always work ok, but we know that there can be problems
      #with certain linux systems not playing nice and blocking intermittently!
      @heartbeat=Time.now
      
      
      @io = open_connection(*args)
      if block_given?
        begin
          yield self
        ensure
          close
        end
      else
        self
      end
    end
    
    class << self
      alias_method :connect, :new
    end

    # Given slave object
    # @example
    #   cl = Client.new
    #   cl.with_slave(1) do |slave|
    #     slave.holding_registers[0..100]
    #   end
    #
    # @param [Integer, #read] uid slave devise
    # @return [Slave] slave object
    def with_slave(uid, &block)
      slave = get_slave(uid, @io)
      slave.debug = debug
      slave.raise_exception_on_mismatch = raise_exception_on_mismatch
      slave.read_retries = read_retries
      slave.read_retry_timeout = read_retry_timeout
      if block_given?
        yield slave
      else
        slave
      end
    end

    # Check connections
    # @return [Boolean]
    def closed?
      @io.closed?
    end

    # Close connections
    def close
      @io.close unless @io.closed?
    end
    
    #used for test purposes only
    def get_io
      @io
    end
    
    #method_missing delegates any unknown calls to the io object, allowing the client
    #to effectively behave as an object of class IO. respond_to? is similarly modified so
    #the object will look like an IO object
    
    def method_missing(meth, *args, &block)
      if @io.respond_to? meth
        @io.send(meth, *args, &block)
      else
        super
      end
    end 
    
    def respond_to?(meth)
      if @io.respond_to? meth
        true
      else
        super
      end
    end


    protected
    def open_connection(*args)
      #Stub conn object
      @io = Object.new

      @io.instance_eval """
        def close
        end

        def closed?
          true
        end
        """
      @io
    end

    def get_slave(uid,io)
      Slave.new(uid, io, @query_lock, @heartbeat)
    end
    
    
  end
end
