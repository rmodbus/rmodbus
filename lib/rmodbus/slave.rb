# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2008-2011  Timin Aleksey
# Copyright (C) 2010  Kelley Reynolds
# Copyright (C) 2011-2012  uCratos Ltd (Steve Gooberman-Hill)
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

require 'timeout'
require 'weakref'

module ModBus
  module Diagnostics
    RETURN_QUERY_DATA=0
    RESTART_COMMS=1
    RETURN_DIAGNOSTIC_REGISTER=2
    CHANGE_ASCII_DELIMITER=3
    FORCE_LISTEN_ONLY=4
    CLEAR_COUNTERS=10
    RETURN_BUS_MSG_COUNT=11
    RETURN_BUS_COMM_ERROR_COUNT=12
    RETURN_BUS_EXCEPTION_COUNT=13
    RETURN_SLAVE_MSG_COUNT=14
    RETURN_SLAVE_NO_RESPONSE_COUNT=15
    RETURN_SLAVE_NAK_COUNT=16
    RETURN_SLAVE_BUSY_COUNT=17
    RETURN_BUS_CHAR_OVERRUN_COUNT=18
    RETURN_OVERRRUN_ERROR_COUNT=19
    CLEAR_OVERRUN_COUNTER=20
    GET_MODBUS_PLUS_STATS=21
  end
  
    
    
  class Slave
    include Errors
    include Debug
    include Options
    # Number of times to retry on read and read timeouts
    attr_accessor :uid, :io
    
    
    Exceptions = {
          1 => IllegalFunction.new("The function code received in the query is not an allowable action for the server"),
          2 => IllegalDataAddress.new("The data address received in the query is not an allowable address for the server"),
          3 => IllegalDataValue.new("A value contained in the query data field is not an allowable value for server"),
          4 => SlaveDeviceFailure.new("An unrecoverable error occurred while the server was attempting to perform the requested action"),
          5 => Acknowledge.new("The server has accepted the request and is processing it, but a long duration of time will be required to do so"),
          6 => SlaveDeviceBus.new("The server is engaged in processing a long duration program command"),
          8 => MemoryParityError.new("The extended file area failed to pass a consistency check")
    }
    
    HEARTBEAT_TIMEOUT=60
    
    
    
    def initialize(uid, io, lock=Mutex.new, hb=Time.now())
	    @uid = uid
      @io = io
      @query_lock=lock #lock to ensure that queries happen one at a time from the master device
                       #optional in arguments at allow test suite not to crash!
      @heartbeat=hb #heartbeat of the connection 
    end
    
    #checks that the slave has acted in the last HEARTBEAT_TIMEOUT seconds. very useful if you are polling a device regularly
    #as some modbus error conditions have been observed to hang the line - so if the heartbeat is stale then 
    #the query_lock hasn't returned form this device or another device
    #returns true if the device is ok
    def heartbeat
      Time.now()-@heartbeat < HEARTBEAT_TIMEOUT
    end  
    
    
    # Returns a ModBus::ReadWriteProxy hash interface for coils
    #
    # @example
    #  coils[addr] => [1]
    #  coils[addr1..addr2] => [1, 0, ..]
    #  coils[addr] = 0 => [0]
    #  coils[addr1..addr2] = [1, 0, ..] => [1, 0, ..]
    #
    # @return [ReadWriteProxy] proxy object
    def coils
      ModBus::ReadWriteProxy.new(self, :coil)
    end

    # Read coils
    #
    # @example
    #  read_coils(addr, ncoils) => [1, 0, ..]
    #
    # @param [Integer] addr address first coil
    # @param [Integer] ncoils number coils
    # @return [Array] coils
    def read_coils(addr, ncoils)
      query("\x1" + addr.to_word + ncoils.to_word).unpack_bits[0..ncoils-1]
    end
    alias_method :read_coil, :read_coils

    # Write a single coil
    #
    # @example
    #  write_single_coil(1, 0) => self
    #
    # @param [Integer] addr address coil
    # @param [Integer] val value coil (0 or other)
    # @return self
    def write_single_coil(addr, val)
      if val == 0
        query("\x5" + addr.to_word + 0.to_word)
      else
        query("\x5" + addr.to_word + 0xff00.to_word)
      end
      self
    end
    alias_method :write_coil, :write_single_coil

    # Write multiple coils
    #
    # @example
    #  write_multiple_coils(1, [0,1,0,1]) => self
    #
    # @param [Integer] addr address first coil
    # @param [Array] vals written coils
    def write_multiple_coils(addr, vals)
      nbyte = ((vals.size-1) >> 3) + 1
      sum = 0
      (vals.size - 1).downto(0) do |i|
        sum = sum << 1
        sum |= 1 if vals[i] > 0
      end

      s_val = ""
      nbyte.times do
        s_val << (sum & 0xff).chr
        sum >>= 8
      end

      query("\xf" + addr.to_word + vals.size.to_word + nbyte.chr + s_val)
      self
    end
    alias_method :write_coils, :write_multiple_coils

    # Returns a ModBus::ReadOnlyProxy hash interface for discrete inputs
    #
    # @example
    #  discrete_inputs[addr] => [1]
    #  discrete_inputs[addr1..addr2] => [1, 0, ..]
    #
    # @return [ReadOnlyProxy] proxy object
    def discrete_inputs
      ModBus::ReadOnlyProxy.new(self, :discrete_input)
    end

    # Read discrete inputs
    #
    # @example
    #  read_discrete_inputs(addr, ninputs) => [1, 0, ..]
    #
    # @param [Integer] addr address first input
    # @param[Integer] ninputs number inputs
    # @return [Array] inputs
    def read_discrete_inputs(addr, ninputs)
      query("\x2" + addr.to_word + ninputs.to_word).unpack_bits[0..ninputs-1]
    end
    alias_method :read_discrete_input, :read_discrete_inputs

    # Returns a read/write ModBus::ReadOnlyProxy hash interface for coils
    #
    # @example
    #  input_registers[addr] => [1]
    #  input_registers[addr1..addr2] => [1, 0, ..]
    #
    # @return [ReadOnlyProxy] proxy object
    def input_registers
      ModBus::ReadOnlyProxy.new(self, :input_register)
    end

    # Read input registers
    #
    # @example
    #  read_input_registers(1, 5) => [1, 0, ..]
    #
    # @param [Integer] addr address first registers
    # @param [Integer] nregs number registers
    # @return [Array] registers
    def read_input_registers(addr, nregs)
      query("\x4" + addr.to_word + nregs.to_word).unpack('n*')
    end
    alias_method :read_input_register, :read_input_registers

    # Returns a ModBus::ReadWriteProxy hash interface for holding registers
    #
    # @example
    #  holding_registers[addr] => [123]
    #  holding_registers[addr1..addr2] => [123, 234, ..]
    #  holding_registers[addr] = 123 => 123
    #  holding_registers[addr1..addr2] = [234, 345, ..] => [234, 345, ..]
    #
    # @return [ReadWriteProxy] proxy object
    def holding_registers
      ModBus::ReadWriteProxy.new(self, :holding_register)
    end

    # Read holding registers
    #
    # @example
    #  read_holding_registers(1, 5) => [1, 0, ..]
    #
    # @param [Integer] addr address first registers
    # @param [Integer] nregs number registers
    # @return [Array] registers
    def read_holding_registers(addr, nregs)
      query("\x3" + addr.to_word + nregs.to_word).unpack('n*')
    end
    alias_method :read_holding_register, :read_holding_registers

    # Write a single holding register
    #
    # @example
    #  write_single_register(1, 0xaa) => self
    #
    # @param [Integer] addr address registers
    # @param [Integer] val written to register
    # @return self
    def write_single_register(addr, val)
      query("\x6" + addr.to_word + val.to_word)
      self
    end
    alias_method :write_holding_register, :write_single_register


    # Write multiple holding registers
    #
    # @example
    #  write_multiple_registers(1, [0xaa, 0]) => self
    #
    # @param [Integer] addr address first registers
    # @param [Array] val written registers
    # @return self
    def write_multiple_registers(addr, vals)
      s_val = ""
      vals.each do |reg|
        s_val << reg.to_word
      end

      query("\x10" + addr.to_word + vals.size.to_word + (vals.size * 2).chr + s_val)
      self
    end
    alias_method :write_holding_registers, :write_multiple_registers

    # Mask a holding register
    #
    # @example
    #   mask_write_register(1, 0xAAAA, 0x00FF) => self
    # @param [Integer] addr address registers
    # @param [Integer] and_mask mask for AND operation
    # @param [Integer] or_mask mask for OR operation
    def mask_write_register(addr, and_mask, or_mask)
      query("\x16" + addr.to_word + and_mask.to_word + or_mask.to_word)
      self
    end
    
    #send diagnostic function
    #all diagnostics are 7 byte queries
    #as per fig 44 of PI+MBUS-300 Rev J
    # @example
    #   diagnostics(Diagnostics::RESTART_COMMS,0x0000) => self
    # @param [Integer] code Diagnostics subfunction code (defined in Diagnostics module)
    # @param [Integer] data Data to send - assumed to be 0x0000 unless otherwise defined 
    def diagnostics(code, data=0x0000)
      query("\x08"+code.to_word+data.to_word)
      self
    end

    # Request pdu to slave device
    #
    # @param [String] pdu request to slave
    # @return [String] received data
    #
    # @raise [ResponseMismatch] the received echo response differs from the request
    # @raise [ModBusTimeout] timed out during read attempt
    # @raise [ModBusException] unknown error
    # @raise [IllegalFunction] function code received in the query is not an allowable action for the server
    # @raise [IllegalDataAddress] data address received in the query is not an allowable address for the server
    # @raise [IllegalDataValue] value contained in the query data field is not an allowable value for server
    # @raise [SlaveDeviceFailure] unrecoverable error occurred while the server was attempting to perform the requested action
    # @raise [Acknowledge] server has accepted the request and is processing it, but a long duration of time will be required to do so
    # @raise [SlaveDeviceBus] server is engaged in processing a long duration program command
    # @raise [MemoryParityError] extended file area failed to pass a consistency check
    def query(request)
      tried = 0
      response = ''
      tp=Thread.current.priority
      begin
        @query_lock.synchronize do
          $log.debug "Lock > #{@uid}"
          @heartbeat=Time.now if @heartbeat<Time.now
          $log.debug "Heartbeat is #{@heartbeat.inspect}"
           
          begin
            Thread.current.priority=2 #increase the priority of the thread while we are running the IO
            clear_buffer
            
            # retries are sorted out outside the critical section!
            timeout(@read_retry_timeout, ModBusTimeout) do
              send_pdu(request)
              response = read_pdu
            end
          rescue ModBusException
            raise
          ensure
            clear_buffer
            Thread.current.priority=tp
            $log.debug "Lock < #{@uid}"
          end
                    
        end #end synchronized section
        
        raise ModBusTimeout.new("Response Failure") if response.nil? || response.bytesize == 0
        
        read_func = response.getbyte(0)
        
        #check for an exception
        if read_func >= 0x80
          exc_id = response.getbyte(1)
          response=''
          raise Exceptions[exc_id] unless Exceptions[exc_id].nil?
          raise ModBusException.new("ModBus : Unknown error response received" )
        end
  
        check_response_mismatch(request, response) if raise_exception_on_mismatch
        response=response[2..-1]
        #end
        
      rescue ModBusTimeout => err
        $log.debug "Timeout of read operation: (#{@read_retries - tried})"
        tried += 1
        retry unless tried >= @read_retries
        raise #ModBus::Errors::ModBusTimeout("Timed out during read attempt")
      rescue ModBusException  => ex
        $log.warn "Slave caught Modbus exception : #{ex.to_s}  at #{ex.backtrace[0]}"
        raise 
      rescue StandardError  => ex
        $log.error "Slave caught exception : #{ex.to_s}  at #{ex.backtrace[0]}"
        raise
      ensure
        response 
      end

      
    end
    
    def renew_connection
      @io=Object.new
    end

    #stub method - can be overwritten in derived classes 
    def clear_buffer
       #nothing to do here
    end


    private
    def check_response_mismatch(request, response)
      read_func = response.getbyte(0)
      data = response[2..-1]
      #Mismatch functional code
      send_func = request.getbyte(0)
      if read_func != send_func
        msg = "Function code is mismatch (expected #{send_func}, got #{read_func})"
      end

      case read_func
      when 1,2
        bc = request.getword(3)/8 + 1
        if data.size != bc
          msg = "Byte count is mismatch (expected #{bc}, got #{data.size} bytes)"
        end
      when 3,4
        rc = request.getword(3) 
        if data.size/2 != rc
          msg = "Register count is mismatch (expected #{rc}, got #{data.size/2} regs)"
        end
      when 5,6
        exp_addr = request.getword(1)
        got_addr = response.getword(1)
        if exp_addr != got_addr
          msg = "Address is mismatch (expected #{exp_addr}, got #{got_addr})"
        end

        exp_val = request.getword(3)
        got_val = response.getword(3)
        if exp_val != got_val
          msg = "Value is mismatch (expected 0x#{exp_val.to_s(16)}, got 0x#{got_val.to_s(16)})"
        end
      when 15,16
        exp_addr = request.getword(1)
        got_addr = response.getword(1)
        if exp_addr != got_addr
          msg = "Address is mismatch (expected #{exp_addr}, got #{got_addr})"
        end
      
        exp_quant = request.getword(3)
        got_quant = response.getword(3)
        if exp_quant != got_quant
          msg = "Quantity is mismatch (expected #{exp_quant}, got #{got_quant})"
        end
      else
        warn "Function (#{read_func}) is not supported raising response mismatch"
      end

      raise ResponseMismatch.new(msg, request, response) if msg

    end
   
    #put the select into a separate method to allow rspec to mock it 
    #rspec doesn't like IO.select
    def read_ready? (timeout)
      IO.select([@io],nil,nil, timeout)
    end
   
    #put the select into a separate method to allow rspec to mock it 
    #rspec doesn't like IO.select
    def write_ready? (timeout)
      IO.select(nil, [@io],nil, timeout)
    end
   
    #stub method to clear the buffer
    #overwritten by RTU
    def clear_buffer
    end    
  end
end
