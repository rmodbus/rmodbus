# -*- coding: ascii
# frozen_string_literal: true

describe ModBus::TCPClient do
  describe "method 'query'" do
    before do
      @uid = 1
      @sock = instance_double("Socket")
      @adu = +"\000\001\000\000\000\001\001"

      expect(Socket).to receive(:tcp).with("127.0.0.1", 1502, nil, nil,
                                           hash_including(:connect_timeout)).and_return(@sock)
      allow(@sock).to receive(:read).with(0).and_return("")
      @cl = ModBus::TCPClient.new("127.0.0.1", 1502)
      @slave = @cl.with_slave(@uid)
    end

    it "sends valid MBAP Header" do
      @adu[0, 2] = @slave.transaction.next.to_word
      expect(@sock).to receive(:write).with(@adu)
      expect(@sock).to receive(:read).with(7).and_return(@adu)
      expect(@slave.query("")).to be_nil
    end

    it "does not throw exception and white next packet if get other transaction" do
      @adu[0, 2] = @slave.transaction.next.to_word
      expect(@sock).to receive(:write).with(@adu)
      expect(@sock).to receive(:read).with(7).and_return("\x00\x02\x00\x00\x00\x01#{@uid.chr}")
      expect(@sock).to receive(:read).with(7).and_return("\x00\x01\x00\x00\x00\x01#{@uid.chr}")

      expect { @slave.query("") }.not_to raise_error
    end

    it "throws timeout exception if do not get own transaction" do
      @slave.read_retries = 2
      @adu[0, 2] = @slave.transaction.next.to_word
      expect(@sock).to receive(:write).at_least(:once).with(/\.*/)
      expect(@sock).to receive(:read).at_least(:once).with(7).and_return("\x00\x03\x00\x00\x00\x01#{@uid.chr}")

      expect { @slave.query("") }.to raise_error(ModBus::Errors::ModBusTimeout, "Timed out during read attempt")
    end

    it "returns only data from PDU" do
      request = "\x3\x0\x6b\x0\x3"
      response = "\x3\x6\x2\x2b\x0\x0\x0\x64"
      @adu = "#{@slave.transaction.next.to_word}\x00\x00\x00\x09#{@uid.chr}#{request}"
      expect(@sock).to receive(:write).with("#{@adu[0, 4]}\x00\x06#{@uid.chr}#{request}")
      expect(@sock).to receive(:read).with(7).and_return(@adu[0, 7])
      expect(@sock).to receive(:read).with(8).and_return(response)

      expect(@slave.query(request)).to eq(response[2..-1])
    end

    it "sugars connect method" do
      ipaddr, port = "127.0.0.1", 502
      expect(Socket).to receive(:tcp).with(ipaddr, port, nil, nil, hash_including(:connect_timeout)).and_return(@sock)
      expect(@sock).to receive(:closed?).and_return(false)
      expect(@sock).to receive(:close)
      ModBus::TCPClient.connect(ipaddr, port) do |cl|
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
      ModBus::TCPClient.new("81.123.231.11", 1999, connect_timeout: 0.001)
    end.to raise_error(ModBus::Errors::ModBusTimeout)
  end
end
