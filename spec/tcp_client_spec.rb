require 'rmodbus/tcp_client'

include ModBus

describe TCPClient, "method 'query'"  do

  UID = 1

  before(:each) do
    @sock = mock("Socket")
    @adu = "\000\001\000\000\000\001\001"

    TCPSocket.should_receive(:new).with('127.0.0.1', 1502).and_return(@sock)
    @sock.stub!(:read).with(0).and_return('')
    @cl = TCPClient.new('127.0.0.1', 1502)
    @slave = @cl.with_slave(1)
  end

  it 'should send valid MBAP Header' do
    @adu[0,2] = @slave.transaction.next.to_word
    @sock.should_receive(:write).with(@adu)
    @sock.should_receive(:read).with(7).and_return(@adu)
    @slave.query('').should == nil
  end

  it 'should throw exception if get other transaction' do
    @adu[0,2] = @slave.transaction.next.to_word
    @sock.should_receive(:write).with(@adu)
    @sock.should_receive(:read).with(7).and_return("\000\002\000\000\000\001" + UID.chr)
    begin
      @slave.query('').should == nil
    rescue Exception => ex
      ex.class.should == Errors::ModBusException
    end
  end

  it 'should return only data from PDU' do
    request = "\x3\x0\x6b\x0\x3"
    response = "\x3\x6\x2\x2b\x0\x0\x0\x64"
    @adu = @slave.transaction.next.to_word + "\x0\x0\x0\x9" + UID.chr + request
    @sock.should_receive(:write).with(@adu[0,4] + "\0\6" + UID.chr + request)
    @sock.should_receive(:read).with(7).and_return(@adu[0,7])
    @sock.should_receive(:read).with(8).and_return(response)

    @slave.query(request).should == response[2..-1]
  end

  it 'should sugar connect method' do
    ipaddr, port = '127.0.0.1', 502
    TCPSocket.should_receive(:new).with(ipaddr, port).and_return(@sock)
    @sock.should_receive(:closed?).and_return(false)
    @sock.should_receive(:close)
    TCPClient.connect(ipaddr, port) do |cl|
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

end
