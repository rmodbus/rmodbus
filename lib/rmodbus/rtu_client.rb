module ModBus
  # RTU client implementation
  # @example
  #   RTUClient.connect('/dev/ttyS1', 9600) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @example
  #   RTUClient.connect('127.0.0.1', 10002) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see TCP#open_tcp_connection
  # @see SP#open_serial_port
  # @see Client#initialize
  class RTUClient < Client
    include RTU
    include SP
    include TCP

    protected
    # Open serial port
    def open_connection(port_or_ipaddr, arg = nil, opts = {})
      if port_or_ipaddr.is_a?(IO) || port_or_ipaddr.respond_to?(:read)
        port_or_ipaddr
      elsif File.exist?(port_or_ipaddr) || port_or_ipaddr.start_with?('/dev') || port_or_ipaddr.start_with?('COM')
        arg ||= 9600
        open_serial_port(port_or_ipaddr, arg, opts)
      else
        arg ||= 10002
        open_tcp_connection(port_or_ipaddr, arg, opts)
      end
    end

    def get_slave(uid, io)
      RTUSlave.new(uid, io)
    end
  end
end
