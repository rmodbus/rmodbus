begin
  require 'rubygems'
rescue
end
require 'rmodbus'

include ModBus

describe RTUViaTCPClient do
    
  before do 
    @sock = mock('Socked')
    TCPSocket.should_receive(:new).with("127.0.0.1", 10002).and_return(@sock)    
    @sock.stub!(:read_timeout=)
    @sock.stub!(:read)

    @mb_client = RTUViaTCPClient.new("127.0.0.1") 
    @mb_client.read_retries = 0
  end

  it "should ignore frame with other UID" do
    request = "\x10\x0\x1\x0\x1\x2\xff\xff" 
    @sock.should_receive(:write).with("\1#{request}\xA6\x31")
    @sock.should_receive(:read).with(2).and_return("\x2\x10")
    @sock.should_receive(:read).with(6).and_return("\x0\x1\x0\x1\x1C\x08")
    lambda {@mb_client.query(request)}.should raise_error(ModBus::Errors::ModBusTimeout)
  end

  it "should ignored frame with incorrect CRC" do
    request = "\x10\x0\x1\x0\x1\x2\xff\xff" 
    @sock.should_receive(:write).with("\1#{request}\xA6\x31")
    @sock.should_receive(:read).with(2).and_return("\x2\x10")
    @sock.should_receive(:read).with(6).and_return("\x0\x1\x0\x1\x1C\x08")
    lambda {@mb_client.query(request)}.should raise_error(ModBus::Errors::ModBusTimeout)
  end
  
  it "should return value of registers"do
    request = "\x3\x0\x1\x0\x1"
    @sock.should_receive(:write).with("\1#{request}\xd5\xca")
    @sock.should_receive(:read).with(2).and_return("\x1\x3")
    @sock.should_receive(:read).with(1).and_return("\x2")
    @sock.should_receive(:read).with(4).and_return("\xff\xff\xb9\xf4")
    @mb_client.query(request).should == "\xff\xff"
  end

 it 'should sugar connect method' do
   ipaddr, port, slave = '127.0.0.1', 502, 3
    TCPSocket.should_receive(:new).with(ipaddr, port).and_return(@sock)
    @sock.should_receive(:closed?).and_return(false)
    @sock.should_receive(:close)
    RTUViaTCPClient.connect(ipaddr, port, slave) do |cl|
      cl.ipaddr.should == ipaddr
      cl.port.should == port
      cl.slave.should == slave
    end
  end

  it 'should have closed? method' do
    @sock.should_receive(:closed?).and_return(false)
    @mb_client.closed?.should == false

    @sock.should_receive(:closed?).and_return(false)
    @sock.should_receive(:close)

    @mb_client.close

    @sock.should_receive(:closed?).and_return(true)
    @mb_client.closed?.should == true
  end

end

