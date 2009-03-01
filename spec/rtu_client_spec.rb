begin
  require 'rubygems'
rescue
end
require 'rmodbus'

include ModBus

describe RTUClient do
    
  before do 
    @port = mock('Serial port')
    SerialPort.should_receive(:new).with("/dev/port1", 9600).and_return(@port)    
    @mb_client = RTUClient.new("/dev/port1", 9600, 1)
    @mb_client.read_retries = 0
  end

  it "should ignore frame with other UID" do
    request = "\x10\x0\x1\x0\x1\x2\xff\xff" 
    @port.should_receive(:write).with("\1#{request}\xA6\x31")
    @port.should_receive(:read).with(3).and_return("\x2\x10\x0")
    lambda {@mb_client.query(request)}.should raise_error(ModBus::Errors::ModBusTimeout)
  end

  it "should calc valid CRC" do
    request = "\x10\x0\x1\x0\x1\x2\xff\xff" 
    @port.should_receive(:write).with("\1#{request}\xA6\x31")
    @port.should_receive(:read).with(3).and_return("\x1\x10\x0")
    @port.should_receive(:read).with(5).and_return("\x1\x0\x1\x1C\x08")
    @mb_client.query(request)
  end
  
  #it "should return value of registers if readed CRC is valid"do
  #  request = "\x3\x0\x1\x0\x1"
  #  @port.should_receive(:write).with("\1#{request}\xd5\xca")
  #  @port.should_receive(:read).and_return("\x1\x3\x2\xff\xff\xb9\xf4")
  #  @mb_client.query(request).should == "\xff\xff"
  #end

  #it "should ignore response if readed CRC is invalid"do
  #  request = "\x3\x0\x1\x0\x1"
  #  @port.should_receive(:write).with("\1#{request}\xd5\xca")
  #  @port.should_receive(:read).and_return("\x1\x3\x2\xff\xff\xb9\xf1")
  #  @mb_client.query(request).should == "\xff\xff"
  #end
end

