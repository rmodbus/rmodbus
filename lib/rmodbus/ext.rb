class String

  if RUBY_VERSION < "1.9"
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

class Array

  # Given an array of 16bit Fixnum, we turn it into 32bit Int in big-endian order, halving the size
  def to_32f
    raise "Array requires an even number of elements to pack to 32bits: was #{self.size}" unless self.size.even?
    self.each_slice(2).map { |(lsb, msb)| [msb, lsb].pack('n*').unpack('g')[0] }
  end

  # Given an array of 32bit Floats, we turn it into an array of 16bit Fixnums, doubling the size
  def from_32f
    self.pack('g*').unpack('n*').each_slice(2).map { |arr| arr.reverse }.flatten
  end

  # Given an array of 16bit Fixnum, we turn it into 32bit Float in big-endian order, halving the size
  def to_32i
    raise "Array requires an even number of elements to pack to 32bits: was #{self.size}" unless self.size.even?
    self.each_slice(2).map { |(lsb, msb)| [msb, lsb].pack('n*').unpack('N')[0] }
  end

  # Given an array of 32bit Fixnum, we turn it into an array of 16bit fixnums, doubling the size
  def from_32i
    self.pack('N*').unpack('n*').each_slice(2).map { |arr| arr.reverse }.flatten
  end

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
