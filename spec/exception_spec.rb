# -*- coding: ascii
require 'rmodbus'

describe ModBus::TCPClient do
  before(:all) do
    @srv = ModBus::TCPServer.new(1502)
    srv_slave = @srv.with_slave(1)
    srv_slave.coils = [0] * 8
    srv_slave.discrete_inputs = [0] * 8
    srv_slave.holding_registers = [0] * 8
    srv_slave.input_registers = [0] * 8
    @srv.start

    @cl = ModBus::TCPClient.new('127.0.0.1', 1502)
    @slave = @cl.with_slave(1)
  end

  it "should raise ProxException" do
    lambda { @slave.holding_registers[0..2] = [0,0] }.should raise_error(ModBus::Errors::ProxyException)
  end

  # Read coil status
  it "should read coil status" do
    @slave.read_coils(0, 4).should == [0] * 4
  end

  it "should raise exception if illegal data address" do
   lambda { @slave.read_coils(501, 34) }.should raise_error(ModBus::Errors::IllegalDataAddress)
  end

  it "should raise exception if too many data" do
   lambda { @slave.read_coils(0, 0x07D1) }.should raise_error(ModBus::Errors::IllegalDataValue)
  end

  # Read input status
  it "should read discrete inputs" do
    @slave.read_discrete_inputs(0, 4).should == [0] * 4
  end

  it "should raise exception if illegal data address" do
   lambda { @slave.read_discrete_inputs(50, 23) }.should raise_error(ModBus::Errors::IllegalDataAddress)
  end

  it "should raise exception if too many data" do
   lambda { @slave.read_discrete_inputs(0, 0x07D1) }.should raise_error(ModBus::Errors::IllegalDataValue)
  end

  # Read holding registers
  it "should read discrete inputs" do
    @slave.read_holding_registers(0, 4).should == [0, 0, 0, 0]
  end

  it "should raise exception if illegal data address" do
   lambda { @slave.read_holding_registers(402, 99) }.should raise_error(ModBus::Errors::IllegalDataAddress)
  end


  it "should raise exception if too many data" do
   lambda { @slave.read_holding_registers(0, 0x007E) }.should raise_error(ModBus::Errors::IllegalDataValue)
  end

  # Read input registers
  it "should read discrete inputs" do
    @slave.read_input_registers(0, 4).should == [0, 0, 0, 0]
  end

  it "should raise exception if illegal data address" do
   lambda { @slave.read_input_registers(402, 9) }.should raise_error(ModBus::Errors::IllegalDataAddress)
  end

  it "should raise exception if too many data" do
   lambda { @slave.read_input_registers(0, 0x007E) }.should raise_error(ModBus::Errors::IllegalDataValue)
  end

  # Force single coil
  it "should force single coil" do
    @slave.write_single_coil(4, 1).should == @slave
    @slave.read_coils(4, 4).should == [1, 0, 0, 0] 
  end

  it "should raise exception if illegal data address" do
   lambda { @slave.write_single_coil(501, true) }.should raise_error(ModBus::Errors::IllegalDataAddress)
  end

  # Preset single register
  it "should preset single register" do
    @slave.write_single_register(4, 0x0AA0).should == @slave
    @slave.read_holding_registers(4, 1).should == [0x0AA0] 
  end

  it "should raise exception if illegal data address" do
   lambda { @slave.write_single_register(501, 0x0AA0) }.should raise_error(ModBus::Errors::IllegalDataAddress)
  end

  # Force multiple coils
  it "should force multiple coils" do
    @slave.write_multiple_coils(4, [0,1,0,1]).should == @slave
    @slave.read_coils(3, 5).should == [0,0,1,0,1]
  end

  it "should raise exception if illegal data address" do
   lambda { @slave.write_multiple_coils(501, [1,0]) }.should raise_error(ModBus::Errors::IllegalDataAddress)
  end

  # Preset multiple registers
  it "should preset multiple registers" do
    @slave.write_multiple_registers(4, [1, 2, 3, 0xAACC]).should == @slave
    @slave.read_holding_registers(3, 5).should == [0, 1, 2, 3, 0xAACC] 
  end

  it "should raise exception if illegal data address" do
   lambda { @slave.write_multiple_registers(501, [1, 2]) }.should raise_error(ModBus::Errors::IllegalDataAddress)
  end

  after(:all) do
    @cl.close unless @cl.closed?
    @srv.stop
  end

end
