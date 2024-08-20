# -*- coding: ascii
# frozen_string_literal: true

describe ModBus::RTUClient do
  describe "method 'query'" do
    before do
      @sock = instance_double(Socket)
      expect(Socket).to receive(:tcp).with("127.0.0.1",
                                           10_002,
                                           nil,
                                           nil,
                                           hash_including(:connect_timeout)).and_return(@sock)
      allow(@sock).to receive(:flush)

      @cl = ModBus::RTUClient.new("127.0.0.1")
      @slave = @cl.with_slave(1)
      @slave.read_retries = 1
    end

    it "ignores frame with other UID" do
      request = "\x10\x00\x01\x00\x01\x02\xff\xff"
      expect(@sock).to receive(:write).with("\x01#{request}\xA6\x31")
      expect(@sock).to receive(:read).with(2).and_return("\x02\x10")
      expect(@sock).to receive(:read).with(6).and_return("\x00\x01\x00\x01\x1C\x08")
      expect { @slave.query(request) }.to raise_error(ModBus::Errors::ModBusTimeout)
    end

    it "ignores frame with incorrect CRC" do
      request = "\x10\x00\x01\x00\x01\x02\xff\xff"
      expect(@sock).to receive(:write).with("\x01#{request}\xA6\x31")
      expect(@sock).to receive(:read).with(2).and_return("\x02\x10")
      expect(@sock).to receive(:read).with(6).and_return("\x00\x01\x00\x01\x1C\x07")
      expect { @slave.query(request) }.to raise_error(ModBus::Errors::ModBusTimeout)
    end

    it "returns value of registers" do
      request = "\x03\x00\x01\x00\x01"
      expect(@sock).to receive(:write).with("\x01#{request}\xd5\xca")
      expect(@sock).to receive(:read).with(2).and_return("\x01\x03")
      expect(@sock).to receive(:read).with(1).and_return("\x02")
      expect(@sock).to receive(:read).with(4).and_return("\xff\xff\xb9\xf4")
      expect(@slave.query(request)).to eq("\xff\xff")
    end

    it "sugars connect method" do
      ipaddr, port = "127.0.0.1", 502
      expect(Socket).to receive(:tcp).with(ipaddr, port, nil, nil, hash_including(:connect_timeout)).and_return(@sock)
      expect(@sock).to receive(:closed?).and_return(false)
      expect(@sock).to receive(:close)
      ModBus::RTUClient.connect(ipaddr, port) do |cl|
        expect(cl.ipaddr).to eq(ipaddr)
        expect(cl.port).to eq(port)
      end
    end

    it "has closed? method" do
      expect(@sock).to receive(:closed?).and_return(false)
      expect(@cl.closed?).to be(false)

      expect(@sock).to receive(:closed?).and_return(false)
      expect(@sock).to receive(:close)

      @cl.close

      expect(@sock).to receive(:closed?).and_return(true)
      expect(@cl.closed?).to be(true)
    end

    it "gives slave object in block" do
      @cl.with_slave(1) do |slave|
        slave.uid = 1
      end
    end
  end

  it "tunes connection timeout" do
    expect do
      ModBus::RTUClient.new("81.123.231.11", 1999, connect_timeout: 0.001)
    end.to raise_error(ModBus::Errors::ModBusTimeout)
  end
end
