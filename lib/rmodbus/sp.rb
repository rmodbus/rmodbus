begin
  require 'serialport'
rescue Exception => e
  raise Gem::LoadError, "Load `serialport` gem for use RTU protocols"
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
    # @return [SerialPort] io serial port
    def open_serial_port(port, baud, opts = {})
      @port, @baud = port, baud

      @data_bits, @stop_bits, @parity, @read_timeout = 8, 1, SerialPort::NONE, 100

      @data_bits = opts[:data_bits] unless opts[:data_bits].nil?
      @stop_bits = opts[:stop_bits] unless opts[:stop_bits].nil?
      @parity = opts[:parity] unless opts[:parity].nil?
      @read_timeout = opts[:read_timeout] unless opts[:read_timeout].nil?

      io = SerialPort.new(@port, @baud, @data_bits, @stop_bits, @parity)
      io.flow_control = SerialPort::NONE
      io.read_timeout = @read_timeout
      io
    end
  end
end
