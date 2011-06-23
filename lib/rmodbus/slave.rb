# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2008-2011  Timin Aleksey
# Copyright (C) 2010  Kelley Reynolds
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
  class Slave
    include Errors
  	include Common
    # Number of times to retry on read and read timeouts
    attr_accessor :read_retries, :read_retry_timeout, :uid

    Exceptions = { 
          1 => IllegalFunction.new("The function code received in the query is not an allowable action for the server"),
          2 => IllegalDataAddress.new("The data address received in the query is not an allowable address for the server"),
          3 => IllegalDataValue.new("A value contained in the query data field is not an allowable value for server"),
          4 => SlaveDeviceFailure.new("An unrecoverable error occurred while the server was attempting to perform the requested action"),
          5 => Acknowledge.new("The server has accepted the request and is processing it, but a long duration of time will be required to do so"),
          6 => SlaveDeviceBus.new("The server is engaged in processing a long duration program command"),
          8 => MemoryParityError.new("The extended file area failed to pass a consistency check")
    }
    def initialize(uid, io)
	    @uid = uid
      @read_retries = 10
      @read_retry_timeout = 1
      @io = io
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
      tried = 0
      begin
        timeout(@read_retry_timeout, ModBusTimeout) do 
          send_pdu(pdu)
          pdu = read_pdu
        end
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
  end
end
