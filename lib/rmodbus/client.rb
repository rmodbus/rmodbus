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
    # Read value *ncoils* coils starting with *addr*
    #
    # Return array of their values
    def read_coils(addr, ncoils)
      query("\x1" + addr.to_word + ncoils.to_word).unpack_bits[0..ncoils-1]
    end

    # Read value *ncoils* discrete inputs starting with *addr*
    #
    # Return array of their values
    def read_discrete_inputs(addr, ncoils)
      query("\x2" + addr.to_word + ncoils.to_word).unpack_bits[0..ncoils-1]
    end

    # Deprecated version of read_discrete_inputs
    def read_discret_inputs(addr, ncoils)
      #warn "[DEPRECATION] `read_discret_inputs` is deprecated.  Please use `read_discrete_inputs` instead."
      read_discrete_inputs(addr, ncoils)
    end

    # Read value *nreg* holding registers starting with *addr*
    #
    # Return array of their values
    def read_holding_registers(addr, nreg) 
      query("\x3" + addr.to_word + nreg.to_word).unpack('n*')
    end

    # Read value *nreg* input registers starting with *addr*
    #
    # Return array of their values
    def read_input_registers(addr, nreg)
      query("\x4" + addr.to_word + nreg.to_word).unpack('n*')
    end

    # Write *val* in *addr* coil 
    #
    # if *val* lager 0 write 1
    #
    # Return self
    def write_single_coil(addr, val)
      if val == 0
        query("\x5" + addr.to_word + 0.to_word)
      else
        query("\x5" + addr.to_word + 0xff00.to_word) 
      end
      self
    end

    # Write *val* in *addr* register
    #
    # Return self
    def write_single_register(addr, val)
      query("\x6" + addr.to_word + val.to_word)
      self
    end

    # Write *val* in coils starting with *addr*
    #
    # *val* it is array of bits
    #
    # Return self
    def write_multiple_coils(addr, val)
      nbyte = ((val.size-1) >> 3) + 1
      sum = 0
      (val.size - 1).downto(0) do |i|
        sum = sum << 1
        sum |= 1 if val[i] > 0
      end
   
      s_val = ""
      nbyte.times do
        s_val << (sum & 0xff).chr
        sum >>= 8 
      end

      query("\xf" + addr.to_word + val.size.to_word + nbyte.chr + s_val)
      self
    end

    # Write *val* in registers starting with *addr*
    #
    # *val* it is array of integer
    #
    # Return self
    def write_multiple_registers(addr, val)
      s_val = ""
      val.each do |reg|
        s_val << reg.to_word
      end

      query("\x10" + addr.to_word + val.size.to_word + (val.size * 2).chr + s_val)
      self
    end

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
