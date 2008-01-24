require 'rmodbus/tcp_client'
require 'rmodbus/adu'

include ModBus

describe TCPClient, "method 'query'"  do

  UID = 1

  before do
    @sock = mock("Socket")
    @adu = mock("ADU")
    ADU.stub!(:new).and_return(@adu)
    @adu.stub!(:serialize).and_return("\000\001\000\000\000\001\001")
    @adu.stub!(:transaction_id).and_return(1)

    TCPSocket.should_receive(:new).with('127.0.0.1', 1502).and_return(@sock)
    @sock.stub!(:read).with(0).and_return('')

    @mb_client = TCPClient.new('127.0.0.1', 1502)
  end

  it 'should send valid MBAP Header' do
    @sock.should_receive(:write).with(@adu.serialize)
    @sock.should_receive(:read).with(7).and_return(@adu.serialize)
    @mb_client.query('').should == nil
  end

  it 'should throw exception if get other transaction' do
    @sock.should_receive(:write).with(@adu.serialize)
    @sock.should_receive(:read).with(7).and_return("\000\002\000\000\000\001" + UID.chr)
    begin
      @mb_client.query('').should == nil
    rescue Exception => ex
      ex.class.should == Errors::ModBusException
    end
  end

  it 'should return only data from PDU' do
    request = "\x3\x0\x6b\x0\x3"
    response = "\x3\x6\x2\x2b\x0\x0\x0\x64"
    ADU.should_receive(:new).with(request, UID).and_return(@adu)
    @adu.should_receive(:serialize).twice.and_return("\x0\x1\x0\x0\x0\x9" + UID.chr + request)
    @sock.should_receive(:write).with(@adu.serialize)
    @sock.should_receive(:read).with(7).and_return("\x0\x1\x0\x0\x0\x9" + UID.chr)
    @sock.should_receive(:read).with(8).and_return(response)

    @mb_client.query(request).should == response[2..-1]
  end

end
