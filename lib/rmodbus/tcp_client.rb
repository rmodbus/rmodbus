module ModBus
  # TCP client implementation
  # @example
  #   TCPClient.connect('127.0.0.1', 502) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see TCP#open_tcp_connection
  # @see Client#initialize
  class TCPClient < Client
    include TCP

    protected
    # Open TCP\IP connection
    def open_connection(ipaddr, port = 502, opts = {})
      open_tcp_connection(ipaddr, port, opts)
    end

    def get_slave(uid, io)
      TCPSlave.new(uid, io)
    end
  end
end
