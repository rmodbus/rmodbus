# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2010  Timin Aleksey
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
  module Modicon
    
    Types = {
        :bool => {:size => 1, :format => ''},
        :uint16 => {:size => 1, :format => 'n'},
        :uint32 => {:size => 2, :format => 'N'},
        :float => {:size => 2, :format => 'g'},
        :double => {:size => 4, :format => 'G'}
    }

    module Client
      include Modicon
      def get_value(addr, opts={})
        get(addr, opts) do |num,size,frm,result| 
        case addr
          when 0..65535
            query("\x1" + addr.to_word + size.to_word).unpack_bits[0,num]
          when 100000..165535
            query("\x2" + (addr-100000).to_word + size.to_word).unpack_bits[0,num]
          when 300000..365535 
            query("\x4" + (addr-300000).to_word + size.to_word).unpack(frm)[0,num]
          when 400000..465535
            query("\x3" + (addr-400000).to_word + size.to_word).unpack(frm)[0,num]
          else
            raise Errors::ModBusException, "Address '#{addr}' is not valid"
        end
        end
      end

      def set_value(addr, val, opts={})
        set(addr, val, opts) do |size, frm, val|
          case addr
            when 0..65535
              write_multiple_coils(addr, val)
            when 400000..465535 
              query("\x10" + (addr-400000).to_word + size.to_word + (size*2).chr + val.pack(frm))
            else
              raise Errors::ModBusException, "Address '#{addr}' is not valid"
          end
        end
      end
    end

    module Server
      include Modicon
      def get_value(addr, opts={})
        get(addr, opts) do |num,size,frm| 
          case addr
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
        end
      end

      def set_value(addr, val, opts={})
        set(addr, val, opts) do |size, frm, val|
          case addr
            when 0..65535
              @coils[addr, size] = val
            when 400000..465535 
              @holding_registers[(addr-400000), size] = val.pack(frm).unpack('n*')
            else
              raise Errors::ModBusException, "Address '#{addr}' is not valid"
          end
        end
      end
    end

    def get(addr, opts = {})
        opts[:number] = 1 if opts[:number].nil?

        if opts[:type].nil?
          opts[:type] = :bool if addr <= 165535
          opts[:type] = :uint16 if addr >= 300000 
        end

        num = opts[:number]
        size = Types[opts[:type]][:size] * num
        frm = Types[opts[:type]][:format] + "*"
        
        result = yield num, size, frm

        num == 1 ?  result[0] :  result
    end

    def set(addr, val, opts={})
      val = [val] unless val.class == Array

      if opts[:type].nil?
        opts[:type] = :bool if addr <= 165535
        opts[:type] = :uint16 if addr >= 300000 
      end

      size = Types[opts[:type]][:size] * val.size
      frm = Types[opts[:type]][:format] + "*"

      yield size, frm, val

      self
    end
  end
end
