# -*- coding: ascii
require 'rmodbus'

describe ModBus::RTUClient do
  describe "method 'query'" do
    before do
      @sock = double('Socket')
      Socket.should_receive(:tcp).with("127.0.0.1", 10002, nil, nil, hash_including(:connect_timeout)).and_return(@sock)
      @sock.stub(:read_timeout=)
      @sock.stub(:flush)

      @cl = ModBus::RTUClient.new("127.0.0.1")
      @slave = @cl.with_slave(1)
      @slave.read_retries = 1
    end

    it "should ignore frame with other UID" do
      request = "\x10\x0\x1\x0\x1\x2\xff\xff"
      @sock.should_receive(:write).with("\1#{request}\xA6\x31")
      @sock.should_receive(:read).with(2).and_return("\x2\x10")
      @sock.should_receive(:read).with(6).and_return("\x0\x1\x0\x1\x1C\x08")
      lambda {@slave.query(request)}.should raise_error(ModBus::Errors::ModBusTimeout)
    end

    it "should ignored frame with incorrect CRC" do
      request = "\x10\x0\x1\x0\x1\x2\xff\xff"
      @sock.should_receive(:write).with("\1#{request}\xA6\x31")
      @sock.should_receive(:read).with(2).and_return("\x2\x10")
      @sock.should_receive(:read).with(6).and_return("\x0\x1\x0\x1\x1C\x08")
      lambda {@slave.query(request)}.should raise_error(ModBus::Errors::ModBusTimeout)
    end

    it "should return value of registers"do
      request = "\x3\x0\x1\x0\x1"
      @sock.should_receive(:write).with("\1#{request}\xd5\xca")
      @sock.should_receive(:read).with(2).and_return("\x1\x3")
      @sock.should_receive(:read).with(1).and_return("\x2")
      @sock.should_receive(:read).with(4).and_return("\xff\xff\xb9\xf4")
      @slave.query(request).should == "\xff\xff"
    end

    it 'should sugar connect method' do
      ipaddr, port = '127.0.0.1', 502
      Socket.should_receive(:tcp).with(ipaddr, port, nil, nil, hash_including(:connect_timeout)).and_return(@sock)
      @sock.should_receive(:closed?).and_return(false)
      @sock.should_receive(:close)
      ModBus::RTUClient.connect(ipaddr, port) do |cl|
        cl.ipaddr.should == ipaddr
        cl.port.should == port
      end
    end

    it 'should have closed? method' do
      @sock.should_receive(:closed?).and_return(false)
      @cl.closed?.should == false

      @sock.should_receive(:closed?).and_return(false)
      @sock.should_receive(:close)

      @cl.close

      @sock.should_receive(:closed?).and_return(true)
      @cl.closed?.should == true
    end

    it 'should give slave object in block' do
      @cl.with_slave(1) do |slave|
        slave.uid = 1
      end
    end
  end

  it "should tune connection timeout" do
    lambda { ModBus::RTUClient.new('81.123.231.11', 1999, :connect_timeout => 0.001) }.should raise_error(ModBus::Errors::ModBusTimeout)
  end
end
