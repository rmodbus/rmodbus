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
require 'rmodbus/exceptions'
require 'gserver'


module ModBus
	
  class TCPServer < GServer
    
    attr_accessor :coils, :discret_inputs, :holding_registers, :input_registers

    Funcs = [1,2,3,4,5,6,15,16]
    
    def initialize(port = 502, uid = 1)
      @coils = []
      @discret_inputs = []
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

        func = req.getbyte(0)

        unless Funcs.include?(func)
          param = { :err => 1 }
        end
      
        case func
          when 1
            param = parse_read_func(req, @coils)
            if param[:err] == 0
              val = @coils[param[:addr],param[:quant]].pack_to_word
              res = func.chr + val.size.chr + val
            end
          when 2
            param = parse_read_func(req, @discret_inputs)
            if param[:err] == 0
              val = @discret_inputs[param[:addr],param[:quant]].pack_to_word
              res = func.chr + val.size.chr + val
            end
          when 3
            param = parse_read_func(req, @holding_registers)
            if param[:err] == 0
              res = func.chr + (param[:quant] * 2).chr + @holding_registers[param[:addr],param[:quant]].pack('n*')
            end
          when 4
            param = parse_read_func(req, @input_registers)
            if param[:err] == 0
              res = func.chr + (param[:quant] * 2).chr + @input_registers[param[:addr],param[:quant]].pack('n*')
            end
          when 5 
            param = parse_write_coil_func(req)
            if param[:err] == 0
              @coils[param[:addr]] = param[:val]
              res = func.chr + req
            end
          when 6
            param = parse_write_register_func(req)
            if param[:err] == 0
              @holding_registers[param[:addr]] = param[:val]
              res = func.chr + req
            end
          when 15
            param = parse_write_multiple_coils_func(req)
            if param[:err] == 0
              @coils[param[:addr],param[:quant]] = param[:val][0,param[:quant]]
              res = func.chr + req
            end
          when 16
            param = parse_write_multiple_registers_func(req)
            if param[:err] == 0
              @holding_registers[param[:addr],param[:quant]] = param[:val][0,param[:quant]]
              res = func.chr + req
            end
        end
        if param[:err] ==  0
          resp = tr + "\0\0" + (res.size + 1).to_word + @uid.chr + res
        else
          resp = tr + "\0\0\0\3" + @uid.chr + (func | 0x80).chr + param[:err].chr
        end 
        io.write resp
      end
    end

    private

    def parse_read_func(req, field)
      quant = req[3,2].unpack('n')[0]

      return { :err => 3} unless quant <= 0x7d
        
      addr = req[1,2].unpack('n')[0]
      return { :err => 2 } unless addr + quant <= field.size
        
      return { :err => 0, :quant => quant, :addr => addr }    
    end

    def parse_write_coil_func(req)
      addr = req[1,2].unpack('n')[0]
      return { :err => 2 } unless addr <= @coils.size

      val = req[3,2].unpack('n')[0]
      return { :err => 3 } unless val == 0 or val == 0xff00
      
      val = 1 if val == 0xff00
      return { :err => 0, :addr => addr, :val => val }  
    end

    def parse_write_register_func(req)
      addr = req[1,2].unpack('n')[0]
      return { :err => 2 } unless addr <= @coils.size

      val = req[3,2].unpack('n')[0]

      return { :err => 0, :addr => addr, :val => val }  
	  end

    def parse_write_multiple_coils_func(req)
      param = parse_read_func(req, @coils)

      if param[:err] == 0
        param = {:err => 0, :addr => param[:addr], :quant => param[:quant], :val => req[6,param[:quant]].unpack_bits }
      end
      param
    end

    def parse_write_multiple_registers_func(req)
      param = parse_read_func(req, @holding_registers)

      if param[:err] == 0
        param = {:err => 0, :addr => param[:addr], :quant => param[:quant], :val => req[6,param[:quant] * 2].unpack('n*')}
      end
      param
    end

	end
end
