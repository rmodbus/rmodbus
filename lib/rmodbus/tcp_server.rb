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
require 'rmodbus/parsers'
require 'gserver'


module ModBus
  class TCPServer < GServer
    include Parsers

    Types = {
        :bool => {:size => 1, :format => ''},
        :uint16 => {:size => 1, :format => 'n'},
        :uint32 => {:size => 2, :format => 'N'},
        :float => {:size => 2, :format => 'g'},
        :double => {:size => 4, :format => 'G'}
    }
   
    attr_accessor :coils, :discrete_inputs, :holding_registers, :input_registers

    def discret_inputs
      warn "[DEPRECATION] `discret_inputs` is deprecated.  Please use `discrete_inputs` instead."
      @discrete_inputs 
    end
  
    def discret_inputs=(val)
      warn "[DEPRECATION] `discret_inputs=` is deprecated.  Please use `discrete_inputs=` instead."
      @discrete_inputs=val
    end
  
   
    def initialize(port = 502, uid = 1)
      @coils = []
      @discrete_inputs = []
      @holding_registers =[]
      @input_registers = []
      @uid = uid
      super(port)
    end

    def serve(io)
      loop do
        req = io.read(7)
        if req[2,2] != "\x00\x00" or req.getbyte(6) != @uid
          io.close
          break
        end
 
        tr = req[0,2]
        len = req[4,2].unpack('n')[0]
        req = io.read(len - 1)

        pdu = exec_req(req, @coils, @discrete_inputs, @holding_registers, @input_registers)

        io.write tr + "\0\0" + (pdu.size + 1).to_word + @uid.chr + pdu
      end
    end

    def get_value(addr, opts={})
      opts[:number] = 1 if opts[:number].nil?

      if opts[:type].nil?
        opts[:type] = :bool if addr <= 165535
        opts[:type] = :uint16 if addr >= 300000 
      end

      num = opts[:number]
      size = Types[opts[:type]][:size] 
      frm = Types[opts[:type]][:format] + "*"

      result = case addr
        when 0..65535
          @coils[addr, num] 
        when 100000..165535
          @discrete_inputs[addr-100000, num]
        when 300000..365535
          @input_registers[addr-300000,size * num].pack('n*').unpack(frm)[0,num]
        when 400000..465535
          @holding_registers[addr-400000,size * num].pack('n*').unpack(frm)[0, num]
        else
          raise Errors::ModBusException, "Address '#{addr}' is not valid"
      end

      if num == 1 
        result[0]
      else
        result
      end
    end

    def set_value(addr, val, opts={})
      val = [val] unless val.class == Array
      case addr
        when 0..65535
          @coils[addr, val.size] = val
        when 400000..465535 
          opts[:type] = :uint16 if opts[:type].nil?
          size = Types[opts[:type]][:size] * val.size
          frm = Types[opts[:type]][:format] + '*'
          @holding_registers[(addr-400000), size * val.size] = val.pack(frm).unpack('n*')
        else
          raise Errors::ModBusException, "Address '#{addr}' is not valid"
      end
      self
    end

  end
end
