# frozen_string_literal: true

class String
  # unpack a string of bytes into an array of integers (0 or 1)
  # representing the bits in those bytes, according to how the
  # ModBus protocol represents coils.
  def unpack_bits
    result = []
    each_byte do |b|
      8.times do
        # least significant bits first within each byte
        result << (b & 0x01)
        b >>= 1
      end
    end
    result
  end

  # Get word by index
  # @param [Integer] index index first bytes of word
  # @return unpacked word
  def getword(index)
    self[index, 2].unpack1("n")
  end
end

class Integer
  # Shortcut for turning an integer into a word
  def to_word
    [self].pack("n")
  end
end

class Array
  # Swap every pair of elements
  def byteswap
    even_elements_check
    each_slice(2).flat_map(&:reverse)
  end
  alias_method :wordswap, :byteswap

  # Given an array of 16-bit unsigned integers, turn it into an array of 16-bit signed integers.
  def to_16i
    pack("n*").unpack("s>*")
  end

  # Given an array of 16-bit unsigned integers, turn it into an array of 32-bit floats, halving the size.
  # The pairs of 16-bit elements should be in big endian order.
  def to_32f
    even_elements_check
    pack("n*").unpack("g*")
  end

  # Given an array of 32-bit floats, turn it into an array of 16-bit unsigned integers, doubling the size.
  def from_32f
    pack("g*").unpack("n*")
  end

  # Given an array of 16-bit unsigned integers, turn it into 32-bit unsigned integers, halving the size.
  # The pairs of 16-bit elements should be in big endian order.
  def to_32u
    even_elements_check
    pack("n*").unpack("N*")
  end

  # Given an array of 16-bit unsigned integers, turn it into 32-bit signed integers, halving the size.
  # The pairs of 16-bit elements should be in big endian order.
  def to_32i
    even_elements_check
    pack("n*").unpack("l>*")
  end

  # Given an array of 32bit unsigned integers, turn it into an array of 16 bit unsigned integers, doubling the size
  def from_32u
    pack("N*").unpack("n*")
  end

  # Given an array of 32bit signed integers, turn it into an array of 16 bit unsigned integers, doubling the size
  def from_32i
    pack("l>*").unpack("n*")
  end

  # pack an array of bits into a string of bytes,
  # as the ModBus protocol dictates for coils
  def pack_bits
    # pack each slice of 8 bits per byte,
    # forward order (bits 0-7 in byte 0, 8-15 in byte 1, etc.)
    # non-multiples of 8 are just 0-padded
    each_slice(8).map do |slice|
      byte = 0
      # within each byte, bit 0 is the LSB,
      # and bit 7 is the MSB
      slice.reverse_each do |bit|
        byte <<= 1
        byte |= 1 if bit.positive?
      end
      byte
    end.pack("C*")
  end

  private

  def even_elements_check
    raise ArgumentError, "Array requires an even number of elements: was #{size}" unless size.even?
  end
end
