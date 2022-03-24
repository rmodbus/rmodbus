# frozen_string_literal: true

class String
  if RUBY_VERSION < "1.9"
    def getbyte(index)
      self[index].to_i
    end
  end

  def unpack_bits
    array_bit = []
    unpack1("b*").each_char do |c|
      array_bit << c.to_i
    end
    array_bit
  end

  # Get word by index
  # @param [Integer] index index first bytes of word
  # @return unpacked word
  def getword(index)
    self[index, 2].unpack1("n")
  end
end

class Integer
  # Shortcut or turning an integer into a word
  def to_word
    [self].pack("n")
  end
end

class Array
  # Given an array of 16bit Fixnum, we turn it into 32bit Int in big-endian order, halving the size
  def to_32f
    raise "Array requires an even number of elements to pack to 32bits: was #{size}" unless size.even?

    each_slice(2).map { |(lsb, msb)| [msb, lsb].pack("n*").unpack1("g") }
  end

  # Given an array of 16bit Fixnum, we turn it into 32bit Int in little-endian order, halving the size
  def to_32f_le
    raise "Array requires an even number of elements to pack to 32bits: was #{size}" unless size.even?

    each_slice(2).map { |(lsb, msb)| [lsb, msb].pack("n*").unpack1("g") }
  end

  # Given an array of 32bit Floats, we turn it into an array of 16bit Fixnums, doubling the size
  def from_32f
    pack("g*").unpack("n*").each_slice(2).map(&:reverse).flatten
  end

  # Given an array of 16bit Fixnum, we turn it into 32bit Float in big-endian order, halving the size
  def to_32i
    raise "Array requires an even number of elements to pack to 32bits: was #{size}" unless size.even?

    each_slice(2).map { |(lsb, msb)| [msb, lsb].pack("n*").unpack1("N") }
  end

  # Given an array of 32bit Fixnum, we turn it into an array of 16bit fixnums, doubling the size
  def from_32i
    pack("N*").unpack("n*").each_slice(2).map(&:reverse).flatten
  end

  def pack_to_word
    word = 0
    s = +""
    mask = 0x01

    each do |bit|
      word |= mask if bit.positive?
      mask <<= 1
      next unless mask == 0x100

      mask = 0x01
      s << word.chr
      word = 0
    end
    if mask == 0x01
      s
    else
      s << word.chr
    end
  end
end
