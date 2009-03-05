# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2009  Timin Aleksey
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

class String

  if RUBY_VERSION.to_f != 1.9
    def getbyte(index)
      self[index].to_i  
    end
	end

  def to_array_int16
    array_int16 = []
    i = 0
    while(i < self.bytesize) do
      array_int16 << self.getbyte(i) * 256 + self.getbyte(i+1)
      i += 2
    end
    array_int16
  end

  def to_array_bytes
    array_bytes = []
    self.each_byte do |b|
      array_bytes << b
    end
    array_bytes
  end
    
  def to_int16
    self.getbyte(0)*256 + self.getbyte(1)
  end

  def to_array_bit
    array_bit = []
    self.each_byte do |byte|
      mask = 0x01 
      8.times {
        unless (mask & byte) == 0
          array_bit << 1
        else
          array_bit << 0
        end
        mask = mask << 1
      }
    end
    array_bit
  end

end

class Integer
  def to_bytes
    (self >> 8).chr + (self & 0xff).chr 
  end
end

class Array

  def to_ints16
    s = ""
    self.each do |int16|
      s << int16.to_bytes
    end
    s
  end

  def bits_to_bytes
    int16 = 0
    s = ""
    mask = 0x01

    self.each do |bit| 
      int16 |= mask if bit > 0
      mask <<= 1
      if mask  == 0x100
        mask = 0x01
        s << int16.chr
        int16 = 0
      end
    end
    s << int16.chr unless mask == 0x01
  end

end

