require 'rmodbus'

include ModBus
include ModBus::Errors

describe ModBus::TCPClient do

  before(:all) do
    @srv = ModBus::TCPServer.new(1502, 1)
    @srv.coils = [0] * 8
    @srv.discrete_inputs = [0] * 8
    @srv.holding_registers = [0] * 8
    @srv.input_registers = [0] * 8
    @srv.start

    @cl =TCPClient.new('127.0.0.1', 1502, 1)
  end

  # Read coil status
  it "should read coil status" do
    @cl.read_coils(0, 4).should == [0] * 4
  end

  it "should raise exception if illegal data address" do
   lambda { @cl.read_coils(501, 34) }.should raise_error(IllegalDataAddress)
  end

  it "should raise exception if too many data" do
   lambda { @cl.read_coils(0, 0x07D1) }.should raise_error(IllegalDataValue)
  end

  # Read input status
  it "should read discrete inputs" do
    @cl.read_discrete_inputs(0, 4).should == [0] * 4
  end

  it "should raise exception if illegal data address" do
   lambda { @cl.read_discrete_inputs(50, 23) }.should raise_error(IllegalDataAddress)
  end

  it "should raise exception if too many data" do
   lambda { @cl.read_discrete_inputs(0, 0x07D1) }.should raise_error(IllegalDataValue)
  end

  # Read holding registers
  it "should read discrete inputs" do
    @cl.read_holding_registers(0, 4).should == [0, 0, 0, 0]
  end

  it "should raise exception if illegal data address" do
   lambda { @cl.read_holding_registers(402, 99) }.should raise_error(IllegalDataAddress)
  end


  it "should raise exception if too many data" do
   lambda { @cl.read_holding_registers(0, 0x007E) }.should raise_error(IllegalDataValue)
  end

  # Read input registers
  it "should read discrete inputs" do
    @cl.read_input_registers(0, 4).should == [0, 0, 0, 0]
  end

  it "should raise exception if illegal data address" do
   lambda { @cl.read_input_registers(402, 9) }.should raise_error(IllegalDataAddress)
  end

  it "should raise exception if too many data" do
   lambda { @cl.read_input_registers(0, 0x007E) }.should raise_error(IllegalDataValue)
  end

  # Force single coil
  it "should force single coil" do
    @cl.write_single_coil(4, 1).should == @cl
    @cl.read_coils(4, 4).should == [1, 0, 0, 0] 
  end

  it "should raise exception if illegal data address" do
   lambda { @cl.write_single_coil(501, true) }.should raise_error(IllegalDataAddress)
  end

  # Preset single register
  it "should preset single register" do
    @cl.write_single_register(4, 0x0AA0).should == @cl
    @cl.read_holding_registers(4, 1).should == [0x0AA0] 
  end

  it "should raise exception if illegal data address" do
   lambda { @cl.write_single_register(501, 0x0AA0) }.should raise_error(IllegalDataAddress)
  end

  # Force multiple coils
  it "should force multiple coils" do
    @cl.write_multiple_coils(4, [0,1,0,1]).should == @cl
    @cl.read_coils(3, 5).should == [0,0,1,0,1]
  end

  it "should raise exception if illegal data address" do
   lambda { @cl.write_multiple_coils(501, [1,0]) }.should raise_error(IllegalDataAddress)
  end

  # Preset multiple registers
  it "should preset multiple registers" do
    @cl.write_multiple_registers(4, [1, 2, 3, 0xAACC]).should == @cl
    @cl.read_holding_registers(3, 5).should == [0, 1, 2, 3, 0xAACC] 
  end

  it "should raise exception if illegal data address" do
   lambda { @cl.write_multiple_registers(501, [1, 2]) }.should raise_error(IllegalDataAddress)
  end

  after(:all) do
    @cl.close unless @cl.closed?
    @srv.stop
  end

end
