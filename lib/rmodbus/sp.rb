begin
  require 'ccutrer-serialport'
rescue LoadError
  warn "[WARNING] Install `ccutrer-serialport` gem for use RTU protocols"
end

module ModBus
  module SP
    attr_reader :port, :baud, :data_bits, :stop_bits, :parity, :read_timeout

    # Open serial port
    # @param [String] port name serial ports ("/dev/ttyS0")
    # @param [Integer] baud rate serial port (default 9600)
    # @param [Hash] opts the options of serial port
    #
    # @option opts [Integer] :data_bits from 5 to 8
    # @option opts [Integer] :stop_bits 1 or 2
    # @option opts [Integer] :parity :none, :even or :odd
    # @return [SerialPort] io serial port
    def open_serial_port(port, baud, opts = {})
      @port, @baud = port, baud

      @data_bits, @stop_bits, @parity = 8, 1, :none

      @data_bits = opts[:data_bits] unless opts[:data_bits].nil?
      @stop_bits = opts[:stop_bits] unless opts[:stop_bits].nil?
      @parity = opts[:parity] unless opts[:parity].nil?

      CCutrer::SerialPort.new(@port, baud: @baud, data_bits: @data_bits, stop_bits: @stop_bits, parity: @parity)
    end
  end
end
