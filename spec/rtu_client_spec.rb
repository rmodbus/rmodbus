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
  end

  it "should calc valid CRC" do
    request = "\x10\x0\x1\x0\x1\x2\xff\xff" 
    @port.should_receive(:write).with("\1#{request}\xA6\x31")
    @port.should_receive(:read).and_return("\x1\x10\x0\x1\x0\x1\x1C\x08")
    @mb_client.query(request)
  end

end

