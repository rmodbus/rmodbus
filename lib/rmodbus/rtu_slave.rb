module ModBus
  # RTU slave implementation
  # @example
  #   RTUClient.connect(port, baud, opts) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see RTUClient#open_connection
  # @see Client#with_slave
  # @see Slave
  class RTUSlave < Slave
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
