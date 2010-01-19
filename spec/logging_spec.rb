require 'rmodbus'

include ModBus

describe TCPClient  do

  UID = 1

  before(:each) do
    @sock = mock("Socket")
    @adu = "\000\001\000\000\000\001\001"

    TCPSocket.should_receive(:new).with('127.0.0.1', 1502).and_return(@sock)
    @sock.stub!(:read).with(0).and_return('')

    @mb_client = TCPClient.new('127.0.0.1', 1502)
  end

  it 'should log rec\send bytes' do
    request, response = "\x3\x0\x6b\x0\x3", "\x3\x6\x2\x2b\x0\x0\x0\x64"
    mock_query(request,response)
    @mb_client.debug = true
    STDOUT.should_receive("<<").with("Tx (12 bytes): [00][01][00][00][00][06][01][03][00][6b][00][03]\n")
    STDOUT.should_receive("<<").with("Rx (15 bytes): [00][01][00][00][00][09][01][03][06][02][2b][00][00][00][64]\n")
    @mb_client.query(request)
  end

  it "should don't logging if debug disable" do
    request, response = "\x3\x0\x6b\x0\x3", "\x3\x6\x2\x2b\x0\x0\x0\x64"
    mock_query(request,response)
    @mb_client.query(request)
  end


  def mock_query(request, response)
    @adu = TCPClient.transaction.next.to_word + "\x0\x0\x0\x9" + UID.chr + request
    @sock.should_receive(:write).with(@adu[0,4] + "\0\6" + UID.chr + request)
    @sock.should_receive(:read).with(7).and_return(@adu[0,7])
    @sock.should_receive(:read).with(8).and_return(response)
  end

end

describe RTUClient do
    
  before do 
    @sp = mock('Serial port')
    SerialPort.should_receive(:new).with("/dev/port1", 9600, 7, 2, SerialPort::ODD).and_return(@sp)    

    @sp.stub!(:read_timeout=)

    @mb_client = RTUClient.new("/dev/port1", 9600, 1, :data_bits => 7, :stop_bits => 2, :parity => SerialPort::ODD)
    @mb_client.read_retries = 0
  end

  it 'should log rec\send bytes' do
    request = "\x3\x0\x1\x0\x1"
    @sp.should_receive(:write).with("\1#{request}\xd5\xca")
    @sp.should_receive(:read).and_return("\x1\x3\x2\xff\xff\xb9\xf4")

    @mb_client.debug = true
    STDOUT.should_receive("<<").with("Tx (8 bytes): [01][03][00][01][00][01][d5][ca]\n")
    STDOUT.should_receive("<<").with("Rx (7 bytes): [01][03][02][ff][ff][b9][f4]\n")

    @mb_client.query(request).should == "\xff\xff"
  end

end

