# frozen_string_literal: true

module ModBus
  # TCP slave implementation
  # @example
  #   TCP.connect('127.0.0.1', 10002) do |cl|
  #     cl.with_slave(uid) do |slave|
  #       slave.holding_registers[0..100]
  #     end
  #   end
  #
  # @see TCP#open_tcp_connection
  # @see Client#with_slave
  # @see Slave
  class TCPSlave < Client::Slave
    attr_reader :transaction

    # @see Slave::initialize
    def initialize(uid, io)
      @transaction = 0
      super(uid, io)
    end

    private

    # overide method for RTU over TCP implamentaion
    # @see Slave#query
    def send_pdu(pdu)
      @transaction = 0 if @transaction.next > 65_535
      @transaction += 1
      msg = "#{@transaction.to_word}\x00\x00#{(pdu.size + 1).to_word}#{@uid.chr}#{pdu}"
      @io.write msg

      log "Tx (#{msg.size} bytes): " + logging_bytes(msg)
    end

    # overide method for RTU over TCP implamentaion
    # @see Slave#query
    def read_pdu
      loop do
        header = @io.read(7)
        next unless header

        trn = header[0, 2].unpack1("n")
        len = header[4, 2].unpack1("n")
        msg = @io.read(len - 1)

        log "Rx (#{(header + msg).size} bytes): " + logging_bytes(header + msg)

        return msg if trn == @transaction

        log "Transaction number mismatch. A packet is ignored."
      end
    end
  end
end
