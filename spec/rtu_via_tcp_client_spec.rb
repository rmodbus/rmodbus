# -*- coding: ascii
require 'rmodbus'

describe ModBus::RTUClient do
  describe "method 'query'" do
    before do
      @sock = double('Socket')
      expect(Socket).to receive(:tcp).with("127.0.0.1", 10002, nil, nil, hash_including(:connect_timeout)).and_return(@sock)
      allow(@sock).to receive(:read_timeout=)
      allow(@sock).to receive(:flush)

      @cl = ModBus::RTUClient.new("127.0.0.1")
      @slave = @cl.with_slave(1)
      @slave.read_retries = 1
    end

    it "should ignore frame with other UID" do
      request = "\x10\x0\x1\x0\x1\x2\xff\xff"
      expect(@sock).to receive(:write).with("\1#{request}\xA6\x31")
      expect(@sock).to receive(:read).with(2).and_return("\x2\x10")
      expect(@sock).to receive(:read).with(6).and_return("\x0\x1\x0\x1\x1C\x08")
      expect {@slave.query(request)}.to raise_error(ModBus::Errors::ModBusTimeout)
    end

    it "should ignored frame with incorrect CRC" do
      request = "\x10\x0\x1\x0\x1\x2\xff\xff"
      expect(@sock).to receive(:write).with("\1#{request}\xA6\x31")
      expect(@sock).to receive(:read).with(2).and_return("\x2\x10")
      expect(@sock).to receive(:read).with(6).and_return("\x0\x1\x0\x1\x1C\x08")
      expect {@slave.query(request)}.to raise_error(ModBus::Errors::ModBusTimeout)
    end

    it "should return value of registers"do
      request = "\x3\x0\x1\x0\x1"
      expect(@sock).to receive(:write).with("\1#{request}\xd5\xca")
      expect(@sock).to receive(:read).with(2).and_return("\x1\x3")
      expect(@sock).to receive(:read).with(1).and_return("\x2")
      expect(@sock).to receive(:read).with(4).and_return("\xff\xff\xb9\xf4")
      expect(@slave.query(request)).to eq("\xff\xff")
    end

    it 'should sugar connect method' do
      ipaddr, port = '127.0.0.1', 502
      expect(Socket).to receive(:tcp).with(ipaddr, port, nil, nil, hash_including(:connect_timeout)).and_return(@sock)
      expect(@sock).to receive(:closed?).and_return(false)
      expect(@sock).to receive(:close)
      ModBus::RTUClient.connect(ipaddr, port) do |cl|
        expect(cl.ipaddr).to eq(ipaddr)
        expect(cl.port).to eq(port)
      end
    end

    it 'should have closed? method' do
      expect(@sock).to receive(:closed?).and_return(false)
      expect(@cl.closed?).to eq(false)

      expect(@sock).to receive(:closed?).and_return(false)
      expect(@sock).to receive(:close)

      @cl.close

      expect(@sock).to receive(:closed?).and_return(true)
      expect(@cl.closed?).to eq(true)
    end

    it 'should give slave object in block' do
      @cl.with_slave(1) do |slave|
        slave.uid = 1
      end
    end
  end

  it "should tune connection timeout" do
    expect { ModBus::RTUClient.new('81.123.231.11', 1999, :connect_timeout => 0.001) }.to raise_error(ModBus::Errors::ModBusTimeout)
  end
end
