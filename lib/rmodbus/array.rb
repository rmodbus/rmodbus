module ModBus
  class Array < ::Array
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
  end
end
