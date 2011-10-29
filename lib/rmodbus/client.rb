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
  # @abstract
  class Client
    include Errors
    include Common

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
      @read_retry_timeout = 1
      @read_retries = 10

      @io = open_connection(*args)
      if block_given?
        yield self
        close
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
      Slave.new(uid, io)
    end
  end
end
