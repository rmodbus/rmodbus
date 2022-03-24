# -*- coding: ascii
# frozen_string_literal: true

require "rmodbus"

describe "Logging" do
  describe ModBus::TCPClient do
    before do
      @uid = 1
      @sock = instance_double("Socket")
      @adu = +"\000\001\000\000\000\001\001"

      expect(Socket).to receive(:tcp).with("127.0.0.1", 1502, nil, nil,
                                           hash_including(:connect_timeout)).and_return(@sock)
      allow(@sock).to receive(:read).with(0).and_return("")

      @slave = ModBus::TCPClient.new("127.0.0.1", 1502).with_slave(@uid)
      @slave.logger = instance_double("Logger")
    end

    it "logs rec/send bytes" do
      request, response = "\x3\x0\x6b\x0\x3", "\x3\x6\x2\x2b\x0\x0\x0\x64"
      mock_query(request, response)
      expect(@slave.logger).to receive(:debug).with("Tx (12 bytes): [00][01][00][00][00][06][01][03][00][6b][00][03]")
      expect(@slave.logger).to receive(:debug).with(
        "Rx (15 bytes): [00][01][00][00][00][09][01][03][06][02][2b][00][00][00][64]"
      )
      @slave.query(request)
    end

    it "doesn't log if debug disable" do
      @slave.logger = nil
      request, response = "\x3\x0\x6b\x0\x3", "\x3\x6\x2\x2b\x0\x0\x0\x64"
      mock_query(request, response)
      @slave.query(request)
    end

    it "logs warn message if transaction mismatch" do
      @adu[0, 2] = @slave.transaction.next.to_word
      expect(@sock).to receive(:write).with(@adu)
      expect(@sock).to receive(:read).with(7).and_return("\x00\x02\x00\x00\x00\x01#{@uid.chr}")
      expect(@sock).to receive(:read).with(7).and_return("\x00\x01\x00\x00\x00\x01#{@uid.chr}")

      expect(@slave.logger).to receive(:debug).with("Tx (7 bytes): [00][01][00][00][00][01][01]")
      expect(@slave.logger).to receive(:debug).with("Rx (7 bytes): [00][02][00][00][00][01][01]")
      expect(@slave.logger).to receive(:debug).with("Transaction number mismatch. A packet is ignored.")
      expect(@slave.logger).to receive(:debug).with("Rx (7 bytes): [00][01][00][00][00][01][01]")

      @slave.query("")
    end

    def mock_query(request, response)
      @adu = "#{@slave.transaction.next.to_word}\x00\x00\x00\x09#{@uid.chr}#{request}"
      expect(@sock).to receive(:write).with("#{@adu[0, 4]}\x00\x06#{@uid.chr}#{request}")
      expect(@sock).to receive(:read).with(7).and_return(@adu[0, 7])
      expect(@sock).to receive(:read).with(8).and_return(response)
    end
  end

  describe ModBus::RTUClient do
    before do
      @sp = instance_double("CCutrer::SerialPort")
      allow(@sp).to receive(:flush)

      expect(CCutrer::SerialPort).to receive(:new).with("/dev/port1", baud: 9600, data_bits: 7, stop_bits: 2,
                                                                      parity: :odd).and_return(@sp)

      @slave = ModBus::RTUClient.new("/dev/port1", 9600, data_bits: 7, stop_bits: 2,
                                                         parity: :odd).with_slave(1)
      @slave.read_retries = 0
    end

    it "logs rec/send bytes" do
      request = "\x3\x0\x1\x0\x1"
      expect(@sp).to receive(:write).with("\1#{request}\xd5\xca")
      expect(@sp).to receive(:read).with(2).and_return("\x1\x3")
      expect(@sp).to receive(:read).with(1).and_return("\x2")
      expect(@sp).to receive(:read).with(4).and_return("\xff\xff\xb9\xf4")

      @slave.logger = instance_double("Logger")
      expect(@slave.logger).to receive(:debug).with("Tx (8 bytes): [01][03][00][01][00][01][d5][ca]")
      expect(@slave.logger).to receive(:debug).with("Rx (7 bytes): [01][03][02][ff][ff][b9][f4]")

      expect(@slave.query(request)).to eq("\xff\xff")
    end
  end
end
