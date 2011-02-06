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

  unless RUBY_VERSION =~ /^1\.9/
    def getbyte(index)
      self[index].to_i
    end
  end

  def unpack_bits
    array_bit = []
    self.unpack('b*')[0].each_char do |c|
        array_bit << c.to_i
    end
    array_bit
  end

end

class Integer

  # Shortcut or turning an integer into a word
  def to_word
    [self].pack('n')
  end

end

class Array

  def pack_to_word
    word = 0
    s = ""
    mask = 0x01

    self.each do |bit| 
      word |= mask if bit > 0
      mask <<= 1
      if mask  == 0x100
        mask = 0x01
        s << word.chr
        word = 0
      end
    end
    unless mask == 0x01
      s << word.chr
    else
      s
    end
  end

end

