module ModBus
  # RTU client implementation
  # @example
  #   RTUClient.connect('/dev/ttyS1', 9600) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see SP#open_serial_port
  # @see Client#initialize
  class RTUClient < Client
    include RTU
    include SP

    protected
    # Open serial port
    def open_connection(port, baud=9600, opts = {})
      open_serial_port(port, baud, opts)
    end

    def get_slave(uid, io)
      RTUSlave.new(uid, io)
    end
  end
end
