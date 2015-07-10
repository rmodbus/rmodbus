# -*- coding: ascii
require 'rmodbus'

describe ModBus::RTUClient do
  before do 
    @sp = double('Serial port')

    SerialPort.should_receive(:new).with("/dev/port1", 9600, 8, 1, 0).and_return(@sp)    
    SerialPort.stub(:public_method_defined?).with(:flush_input).and_return(true)

    @sp.stub(:read_timeout=)
    @sp.stub(:class).and_return(SerialPort)
    @sp.should_receive(:flow_control=).with(SerialPort::NONE)
    @sp.stub(:flush_input)

    @cl = ModBus::RTUClient.new("/dev/port1", 9600, :data_bits => 8, :stop_bits => 1, :parity => SerialPort::NONE)
    @slave = @cl.with_slave(1)
    @slave.read_retries = 1
  end

  it "should ignore frame with other UID" do
    request = "\x10\x0\x1\x0\x1\x2\xff\xff" 
    @sp.should_receive(:write).with("\1#{request}\xA6\x31")
    @sp.should_receive(:read).with(2).and_return("\x2\x10")
    @sp.should_receive(:read).with(6).and_return("\x0\x1\x0\x1\x1C\x08")
    lambda {@slave.query(request)}.should raise_error(ModBus::Errors::ModBusTimeout)
  end

  it "should ignored frame with incorrect CRC" do
    request = "\x10\x0\x1\x0\x1\x2\xff\xff" 
    @sp.should_receive(:write).with("\1#{request}\xA6\x31")
    @sp.should_receive(:read).with(2).and_return("\x2\x10")
    @sp.should_receive(:read).with(6).and_return("\x0\x1\x0\x1\x1C\x08")
    lambda {@slave.query(request)}.should raise_error(ModBus::Errors::ModBusTimeout)
  end
  
  it "should return value of registers"do
    request = stab_valid_request
    @slave.query(request).should == "\xff\xff"
  end

  it 'should sugar connect method' do
    port, baud = "/dev/port1", 4800
    SerialPort.should_receive(:new).with(port, baud, 8, 1, SerialPort::NONE).and_return(@sp)    
    @sp.should_receive(:closed?).and_return(false)
    @sp.should_receive(:close)
    @sp.should_receive(:flow_control=).with(SerialPort::NONE)
    ModBus::RTUClient.connect(port, baud) do |cl|
      cl.port.should == port
      cl.baud.should == baud
      cl.data_bits.should == 8
      cl.stop_bits.should == 1
      cl.parity.should == SerialPort::NONE
    end
  end

  it 'should have closed? method' do
    @sp.should_receive(:closed?).and_return(false)
    @cl.closed?.should == false

    @sp.should_receive(:closed?).and_return(false)
    @sp.should_receive(:close)

    @cl.close

    @sp.should_receive(:closed?).and_return(true)
    @cl.closed?.should == true
  end

  it 'should give slave object in block' do
    @cl.with_slave(1) do |slave|
      slave.uid = 1
    end
  end

  def stab_valid_request
    request = "\x3\x0\x1\x0\x1"
    @sp.should_receive(:write).with("\1#{request}\xd5\xca")
    @sp.should_receive(:read).with(2).and_return("\x1\x3")
    @sp.should_receive(:read).with(1).and_return("\x2")
    @sp.should_receive(:read).with(4).and_return("\xff\xff\xb9\xf4")

    request
  end
end

