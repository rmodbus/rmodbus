module ModBus
  # RTU over TCP client implementation
  # @example
  #   RTUViaTCPClient.connect('127.0.0.1', 10002) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see TCP#open_tcp_connection
  # @see Client#initialize
  class RTUViaTCPClient < Client
		include RTU
		include TCP

    protected

    def open_connection(ipaddr, port = 10002, opts = {})
      io = open_tcp_connection(ipaddr, port, opts)
		end

    def get_slave(uid, io)
      RTUViaTCPSlave.new(uid, io)
    end
	end
end
