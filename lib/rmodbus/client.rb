# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2008  Timin Aleksey
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

require 'rmodbus/common'
require 'rmodbus/exceptions'
require 'rmodbus/ext'


module ModBus

  class Client
  
    include Errors
  	include Common
    # Number of times to retry on connection and read timeouts
    attr_accessor :read_retries

    def connection_retries
      warn "[DEPRECATION] `connection_retries` is deprecated.  Please don't use it."
      @connection_retries
    end

    def connection_retries=(value)
      warn "[DEPRECATION] `connection_retries=` is deprecated.  Please don't use it."
      @connection_retries = value
    end


    Exceptions = { 
          1 => IllegalFunction.new("The function code received in the query is not an allowable action for the server"),
          2 => IllegalDataAddress.new("The data address received in the query is not an allowable address for the server"),
          3 => IllegalDataValue.new("A value contained in the query data field is not an allowable value for server"),
          4 => SlaveDeviceFailure.new("An unrecoverable error occurred while the server was attempting to perform the requested action"),
          5 => Acknowledge.new("The server has accepted the request and is processing it, but a long duration of time will be required to do so"),
          6 => SlaveDeviceBus.new("The server is engaged in processing a long duration program command"),
          8 => MemoryParityError.new("The extended file area failed to pass a consistency check")
    }
    def initialize
      @connection_retries = 10
      @read_retries = 10
    end

    # Returns a ModBus::ReadWriteProxy hash interface for coils
    #
    # call-seq:
    #  coils[addr] => [1]
    #  coils[addr1..addr2] => [1, 0, ..]
    #  coils[addr] = 0 => [0]
    #  coils[addr1..addr2] = [1, 0, ..] => [1, 0, ..]
    #
    def coils
      ModBus::ReadWriteProxy.new(self, :coil)
    end
    
    # Read +ncoils+ coils starting at address +addr+ and return their values as an array
    # 
    # call-seq:
    #  read_coils(addr, ncoils) => [1, 0, ..]
    #
    def read_coils(addr, ncoils)
      query("\x1" + addr.to_word + ncoils.to_word).unpack_bits[0..ncoils-1]
    end
    alias_method :read_coil, :read_coils
    
    # Set the coil at address +addr+ to +val+
    # 
    # call-seq:
    #  write_single_coil(addr, val) => self
    #
    def write_single_coil(addr, val)
      if val == 0
        query("\x5" + addr.to_word + 0.to_word)
      else
        query("\x5" + addr.to_word + 0xff00.to_word) 
      end
      self
    end
    alias_method :write_coil, :write_single_coil

    # Set the coils to +vals+ starting at address +addr+
    # 
    # call-seq:
    #  write_multiple_coils(addr, vals) => self
    #
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
    # call-seq:
    #  discrete_inputs[addr] => [1]
    #  discrete_inputs[addr1..addr2] => [1, 0, ..]
    #
    def discrete_inputs
      ModBus::ReadOnlyProxy.new(self, :discrete_input)
    end

    # Read +ninputs+ discrete inputs starting at address +addr+ and return their values as an array
    # 
    # call-seq:
    #  read_discrete_inputs(addr, ninputs) => [1, 0, ..]
    #
    def read_discrete_inputs(addr, ninputs)
      query("\x2" + addr.to_word + ninputs.to_word).unpack_bits[0..ninputs-1]
    end
    alias_method :read_discrete_input, :read_discrete_inputs
    alias_method :read_discret_inputs, :read_discrete_inputs # Deprecated method call

    # Returns a read/write ModBus::ReadOnlyProxy hash interface for coils
    #
    # call-seq:
    #  input_registers[addr] => [1]
    #  input_registers[addr1..addr2] => [1, 0, ..]
    #
    def input_registers
      ModBus::ReadOnlyProxy.new(self, :input_register)
    end

    # Starting at a particular address, read +nregs+ coils and return their values as an array
    # 
    # call-seq:
    #  read_input_registers(addr, nregs) => [1, 0, ..]
    #
    def read_input_registers(addr, nregs, &block)
      if block_given?
        yield query("\x4" + addr.to_word + nregs.to_word)
      else
        query("\x4" + addr.to_word + nregs.to_word).unpack('n*')
      end
    end
    alias_method :read_input_register, :read_input_registers
        
    # Returns a ModBus::ReadWriteProxy hash interface for holding registers
    #
    # call-seq:
    #  holding_registers[addr] => [123]
    #  holding_registers[addr1..addr2] => [123, 234, ..]
    #  holding_registers[addr] = 123 => 123
    #  holding_registers[addr1..addr2] = [234, 345, ..] => [234, 345, ..]
    #
    def holding_registers
      ModBus::ReadWriteProxy.new(self, :holding_register)
    end

    # Read +nregs+ registers starting at address +addr+ and return their values as an array
    # 
    # call-seq:
    #  read_holding_registers(addr, nregs) => [1, 0, ..]
    #
    def read_holding_registers(addr, nregs, &block) 
      if block_given?
        yield query("\x3" + addr.to_word + nregs.to_word)
      else
        query("\x3" + addr.to_word + nregs.to_word).unpack('n*')
      end
    end
    alias_method :read_holding_register, :read_holding_registers

    # Set the holding register at address +addr+ to +val+
    # 
    # call-seq:
    #  write_single_register(addr, val) => self
    #
    def write_single_register(addr, val)
      query("\x6" + addr.to_word + val.to_word)
      self
    end
    alias_method :write_holding_register, :write_single_register


    # Set the registers to +vals+ starting at address +addr+
    # 
    # call-seq:
    #  write_multiple_registers(addr, vals) => self
    #
    def write_multiple_registers(addr, vals)
      s_val = ""
      vals.each do |reg|
        s_val << reg.to_word
      end

      query("\x10" + addr.to_word + vals.size.to_word + (vals.size * 2).chr + s_val)
      self
    end
    alias_method :write_holding_registers, :write_multiple_registers

    # Write *current value & and_mask | or mask in *addr* register
    #
    # Return self
    def mask_write_register(addr, and_mask, or_mask)
      query("\x16" + addr.to_word + and_mask.to_word + or_mask.to_word)
      self  
    end

    def query(pdu)    
      send_pdu(pdu)

      tried = 0
      begin
        timeout(1, ModBusTimeout) { pdu = read_pdu }
      rescue ModBusTimeout => err
	    log "Timeout of read operation: (#{@read_retries - tried})"
        tried += 1
        retry unless tried >= @read_retries
        raise ModBusTimeout.new, "Timed out during read attempt"
      end
    
      return nil if pdu.size == 0

      if pdu.getbyte(0) >= 0x80
        exc_id = pdu.getbyte(1)
        raise Exceptions[exc_id] unless Exceptions[exc_id].nil?

        raise ModBusException.new, "Unknown error"
      end
      pdu[2..-1]
    end

    protected

    def send_pdu(pdu)
    end

    def read_pdu
    end

    def close
    end

	# We have to read specific amounts of numbers of bytes from the network depending on the function code and content
    def read_rtu_response(io)
	  # Read the slave_id and function code
	  msg = io.read(2)
	  function_code = msg.getbyte(1)
      case function_code
	    when 1,2,3,4 then
	      # read the third byte to find out how much more 
          # we need to read + CRC
		  msg += io.read(1)
		  msg += io.read(msg.getbyte(2)+2)
	    when 5,6,15,16 then
		  # We just read in an additional 6 bytes
		  msg += io.read(6)
        when 22 then
          msg += io.read(8)
        when 0x80..0xff then
          msg += io.read(4)
	    else
		  raise ModBus::Errors::IllegalFunction, "Illegal function: #{function_code}"
	  end      
	end

  end

end
