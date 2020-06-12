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
  class RTUSlave < Client::Slave
    include RTU

    private
    # overide method for RTU implamentaion
    # @see Slave#query
    def send_pdu(pdu)
      msg = @uid.chr + pdu
      msg << [crc16(msg)].pack("S<")

      clean_input_buff
      @io.write msg

      log "Tx (#{msg.size} bytes): " + logging_bytes(msg)
    end

    # overide method for RTU implamentaion
    # @see Slave#query
    def read_pdu
      msg = read_rtu_response(@io)

      log "Rx (#{msg.size} bytes): " + logging_bytes(msg)

      if msg.getbyte(0) == @uid
        return msg[1..-3] if msg[-2,2].unpack('S<')[0] == crc16(msg[0..-3])
        log "Ignore package: don't match CRC"
      else
        log "Ignore package: don't match uid ID"
      end
      loop do
        #waite timeout
        sleep(0.1)
      end
    end
  end
end
