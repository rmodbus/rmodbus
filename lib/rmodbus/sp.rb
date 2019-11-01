begin
  require 'rubyserial'
rescue Exception => e
  warn "[WARNING] Install `rubyserial` gem for use RTU protocols"
end

module ModBus
  module SP
    attr_reader :port, :baud, :data_bits, :stop_bits, :parity, :read_timeout
    # Open serial port
    # @param [String] port name serial ports ("/dev/ttyS0" POSIX, "com1" - Windows)
    # @param [Integer] baud rate serial port (default 9600)
    # @param [Hash] opts the options of serial port
    #
    # @option opts [Integer] :data_bits from 5 to 8
    # @option opts [Integer] :stop_bits 1 or 2
    # @option opts [Integer] :parity NONE, EVEN or ODD
    # @option opts [Integer] :read_timeout default 100 ms
    # @return [Serial] io serial port
    def open_serial_port(port, baud, opts = {})
      @port, @baud = port, baud

      @data_bits, @stop_bits, @parity, @read_timeout = 8, 1, :none, 100

      @data_bits = opts[:data_bits] unless opts[:data_bits].nil?
      @stop_bits = opts[:stop_bits] unless opts[:stop_bits].nil?
      @parity = opts[:parity] unless opts[:parity].nil?
      @read_timeout = opts[:read_timeout] unless opts[:read_timeout].nil?

      io = Serial.new(@port, @baud, @data_bits, @stop_bits, @parity)
      io.read_timeout = @read_timeout
      io
    end
  end
end
