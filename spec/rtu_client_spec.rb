# -*- coding: ascii
require 'rmodbus'

describe ModBus::RTUClient do
  before do 
    @sp = double('Serial port')
    allow(@sp).to receive(:flush)

    expect(CCutrer::SerialPort).to receive(:new).with("/dev/port1", baud: 9600, data_bits: 8, stop_bits: 1, parity: :none).and_return(@sp)    

    @cl = ModBus::RTUClient.new("/dev/port1", 9600, :data_bits => 8, :stop_bits => 1, :parity => :none)
    @slave = @cl.with_slave(1)
    @slave.read_retries = 1
  end

  it "should ignore frame with other UID" do
    request = "\x10\x0\x1\x0\x1\x2\xff\xff" 
    expect(@sp).to receive(:write).with("\1#{request}\xA6\x31")
    expect(@sp).to receive(:read).with(2).and_return("\x2\x10")
    expect(@sp).to receive(:read).with(6).and_return("\x0\x1\x0\x1\x1C\x08")
    expect {@slave.query(request)}.to raise_error(ModBus::Errors::ModBusTimeout)
  end

  it "should ignored frame with incorrect CRC" do
    request = "\x10\x0\x1\x0\x1\x2\xff\xff" 
    expect(@sp).to receive(:write).with("\1#{request}\xA6\x31")
    expect(@sp).to receive(:read).with(2).and_return("\x2\x10")
    expect(@sp).to receive(:read).with(6).and_return("\x0\x1\x0\x1\x1C\x08")
    expect {@slave.query(request)}.to raise_error(ModBus::Errors::ModBusTimeout)
  end
  
  it "should return value of registers"do
    request = stab_valid_request
    expect(@slave.query(request)).to eq("\xff\xff")
  end

  it 'should sugar connect method' do
    port, baud = "/dev/port1", 4800
    expect(CCutrer::SerialPort).to receive(:new).with(port, baud: baud, data_bits: 8, stop_bits: 1, parity: :none).and_return(@sp)    
    expect(@sp).to receive(:closed?).and_return(false)
    expect(@sp).to receive(:close)
    ModBus::RTUClient.connect(port, baud) do |cl|
      expect(cl.port).to eq(port)
      expect(cl.baud).to eq(baud)
      expect(cl.data_bits).to eq(8)
      expect(cl.stop_bits).to eq(1)
      expect(cl.parity).to eq(:none)
    end
  end

  it 'should have closed? method' do
    expect(@sp).to receive(:closed?).and_return(false)
    expect(@cl.closed?).to eq(false)

    expect(@sp).to receive(:closed?).and_return(false)
    expect(@sp).to receive(:close)

    @cl.close

    expect(@sp).to receive(:closed?).and_return(true)
    expect(@cl.closed?).to eq(true)
  end

  it 'should give slave object in block' do
    @cl.with_slave(1) do |slave|
      slave.uid = 1
    end
  end

  def stab_valid_request
    request = "\x3\x0\x1\x0\x1"
    expect(@sp).to receive(:write).with("\1#{request}\xd5\xca")
    expect(@sp).to receive(:read).with(2).and_return("\x1\x3")
    expect(@sp).to receive(:read).with(1).and_return("\x2")
    expect(@sp).to receive(:read).with(4).and_return("\xff\xff\xb9\xf4")

    request
  end
end

