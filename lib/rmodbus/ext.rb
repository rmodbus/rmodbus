class String
  def unpack_bits
    array_bit = ModBus::Array.new
    self.unpack('b*')[0].each_char do |c|
      array_bit << c.to_i
    end
    array_bit
  end

  # Get word by index
  # @param [Integer] i index first bytes of word
  # @return unpacked word
  def getword(i)
    self[i,2].unpack('n')[0]
  end
end

class Integer
  # Shortcut or turning an integer into a word
  def to_word
    [self].pack('n')
  end
end
