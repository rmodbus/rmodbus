# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2010  Timin Aleksey
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
  # Module for implementation ModBus server
  module Server
    Funcs = [1,2,3,4,5,6,15,16]

    attr_accessor :coils, :discrete_inputs, :holding_registers, :input_registers, :uid
    @coils = []
    @discrete_inputs = []
    @holding_registers =[]
    @input_registers = []

    private

    def exec_req(req, coils, discrete_inputs, holding_registers, input_registers)
      func = req.getbyte(0)

      unless Funcs.include?(func)
        params = { :err => 1 }
      end

      case func
        when 1
          params = parse_read_func(req, coils)
          if params[:err] == 0
            val = coils[params[:addr],params[:quant]].pack_to_word
            pdu = func.chr + val.size.chr + val
          end
        when 2
          params = parse_read_func(req, discrete_inputs)
          if params[:err] == 0
            val = discrete_inputs[params[:addr],params[:quant]].pack_to_word
            pdu = func.chr + val.size.chr + val
          end
        when 3
          params = parse_read_func(req, holding_registers)
          if params[:err] == 0
            pdu = func.chr + (params[:quant] * 2).chr + holding_registers[params[:addr],params[:quant]].pack('n*')
          end
        when 4
          params = parse_read_func(req, input_registers)
          if params[:err] == 0
            pdu = func.chr + (params[:quant] * 2).chr + input_registers[params[:addr],params[:quant]].pack('n*')
          end
        when 5
          params = parse_write_coil_func(req)
          if params[:err] == 0
            coils[params[:addr]] = params[:val]
            pdu = req
          end
        when 6
          params = parse_write_register_func(req)
          if params[:err] == 0
            holding_registers[params[:addr]] = params[:val]
            pdu = req
          end
        when 15
          params = parse_write_multiple_coils_func(req)
          if params[:err] == 0
            coils[params[:addr],params[:quant]] = params[:val][0,params[:quant]]
            pdu = req[0,5]
          end
        when 16
          params = parse_write_multiple_registers_func(req)
          if params[:err] == 0
            holding_registers[params[:addr],params[:quant]] = params[:val][0,params[:quant]]
            pdu = req[0,5]
          end
      end

      if params[:err] == 0
        pdu
      else
        pdu = (func | 0x80).chr + params[:err].chr
      end
    end

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
      params = parse_read_func(req, @coils)

      if params[:err] == 0
        params = {:err => 0, :addr => params[:addr], :quant => params[:quant], :val => req[6,params[:quant]].unpack_bits }
      end
      params
    end

    def parse_write_multiple_registers_func(req)
      params = parse_read_func(req, @holding_registers)

      if params[:err] == 0
        params = {:err => 0, :addr => params[:addr], :quant => params[:quant], :val => req[6,params[:quant] * 2].unpack('n*')}
      end
      params
    end

  end
end
