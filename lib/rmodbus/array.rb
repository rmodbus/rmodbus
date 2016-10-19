module ModBus
  class Array < ::Array
    # Given an array of 16bit Fixnum, we turn it into 32bit Int in specified order, halving the size
    def to_32f(endianness = :big)
      raise "Endianness must be :big or :little, got #{endian.inspect}" unless [:big, :little].include?(endianness)
      raise "Array requires an even number of elements to pack to 32bits: was #{self.size}" unless self.size.even?

      if endianness == :big
        self.each_slice(2).map { |(lsb, msb)| [msb, lsb].pack('n*').unpack('g')[0] }
      else
        self.each_slice(2).map { |(lsb, msb)| [lsb, msb].pack('n*').unpack('g')[0] }
      end
    end

    # Given an array of 32bit Floats, we turn it into an array of 16bit Fixnums, doubling the size
    def from_32f(endianness = :big)
      raise "Endianness must be :big or :little, got #{endian.inspect}" unless [:big, :little].include?(endianness)

      if endianness == :big
        self.pack('g*').unpack('n*').each_slice(2).map { |arr| arr.reverse }.flatten
      else
        self.pack('g*').unpack('n*').flatten
      end
    end

    # Given an array of 16bit Fixnum, we turn it into 32bit Float in specified order, halving the size
    def to_32i(endianness = :big)
      raise "Endianness must be :big or :little, got #{endian.inspect}" unless [:big, :little].include?(endianness)
      raise "Array requires an even number of elements to pack to 32bits: was #{self.size}" unless self.size.even?

      if endianness == :big
        self.each_slice(2).map { |(lsb, msb)| [msb, lsb].pack('n*').unpack('N')[0] }
      else
        self.each_slice(2).map { |(lsb, msb)| [lsb, msb].pack('n*').unpack('N')[0] }
      end
    end

    # Given an array of 32bit Fixnum, we turn it into an array of 16bit fixnums, doubling the size
    def from_32i(endianness = :big)
      raise "Endianness must be :big or :little, got #{endian.inspect}" unless [:big, :little].include?(endianness)

      if endianness == :big
        self.pack('N*').unpack('n*').each_slice(2).map { |arr| arr.reverse }.flatten
      else
        self.pack('N*').unpack('n*').flatten
      end
    end
  end
end
