module ModBus
  # RTU over TCP slave implementation
  # @example
  #   RTUViaTCP.connect('127.0.0.1', 10002) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see RTUViaTCPClient#open_connection
  # @see Client#with_slave
  # @see Slave
  class RTUViaTCPSlave < Slave
		include RTU

    private
    # overide method for RTU implementaion
    # @see Slave#query
    def send_pdu(pdu)
      send_rtu_pdu(pdu)
    end

    # overide method for RTU implementaion
    # @see Slave#query
    def read_pdu
      read_rtu_pdu
    end
	end
end
