require 'lib/rmodbus/tcp_client'

include ModBus


describe TCPClient, "method 'query'"  do

  UID = 1
  

  before do
    @sock = mock("Socket")
    TCPSocket.should_receive(:new).with('127.0.0.1', 1502).and_return(@sock)
    @sock.stub!(:read).with(0).and_return('')

    @mb_client = TCPClient.new('127.0.0.1', 1502)
  end

  it 'should send valid MBAP Header' do
    @sock.should_receive(:write).with("\000\001\000\000\000\001" + UID.chr)
    @sock.should_receive(:read).with(7).and_return("\000\001\000\000\000\001" + UID.chr)
    @mb_client.query('').should == nil
  end

  it 'should throw exception if get other transaction' do
    @sock.should_receive(:write).with("\000\001\000\000\000\001" + UID.chr)
    @sock.should_receive(:read).with(7).and_return("\000\002\000\000\000\001" + UID.chr)
    begin
      @mb_client.query('').should == nil
    rescue Exception => ex
      ex.class.should == Errors::ModBusException
    end
  end

 # it 'should return only data from PDU' do
 #   data_s = "\000\001\002\003"
 #   query_s = "\003\000\000\000\002"
 #   @sock.should_receive(:write).with("\000\001\000\000\000\006" + UID.chr + query_s)
 #   @sock.should_receive(:read).with(7).and_return("\000\001\000\000\000\010" + UID.chr)
 #   @sock.should_receive(:read).with(3).and_return("\003\004" + data_s)
 #   @mb_client.query(query_s).should == data_s
 # end

end
