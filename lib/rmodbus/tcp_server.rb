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
    
    attr_accessor :coils

    @@funcs = [1]
    
    def initialize(port = 502, uid = 1)
      @coils = []
      @uid = uid
      super(port)
    end

    def serve(io)
      req = io.read(7)
      if req[2,2] != "\x00\x00" or req[6].to_i != @uid
        io.close
        return
      end

      tr = req[0,2]
      len = req[4,2].to_int16
      req = io.read(len - 1)
      func = req[0].to_i

      unless @@funcs.include?(func)
        io.write get_err(tr, func,1)
        return
      end
      
      quant = req[3,2].to_int16
      unless quant <= 0x7d
        io.write get_err(tr, func,3)
        return
      end

      addr = req[1,2].to_int16
      unless addr + quant <= coils.size
        io.write get_err(tr, func,2)
        return
      end

      res = func.chr + (quant * 2).chr + coils[addr,quant].bits_to_bytes
      io.write tr + "\0\0" + (res.size + 1).to_bytes + @uid.chr + res
    end

    private

    def get_err(tr, func, code)
      tr + "\0\0\0\3\1" + (func | 0x80).chr + code.chr
    end

	end
	
end
