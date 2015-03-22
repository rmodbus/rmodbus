# -*- coding: ascii
require 'rmodbus'

describe Array do
  before do
    @slave = double('ModBus Slave')
    @coil_proxy = ModBus::ReadWriteProxy.new(@slave, :coil)
    @discrete_input_proxy = ModBus::ReadOnlyProxy.new(@slave, :discrete_input)
    @holding_register_proxy = ModBus::ReadWriteProxy.new(@slave, :holding_register)
    @input_register_proxy = ModBus::ReadOnlyProxy.new(@slave, :input_register)
  end

  # Handle all of the coil methods
  it "should call read_coil" do
    @slave.should_receive(:read_coil).with(0, 1)
    @coil_proxy[0]
  end
  it "should call read_coils" do
    @slave.should_receive(:read_coils).with(0, 2)
    @coil_proxy[0..1]
  end
  it "should call write_coil" do
    @slave.should_receive(:write_coil).with(0, 1)
    @coil_proxy[0] = 1
  end
  it "should call write_coils" do
    @slave.should_receive(:write_coils).with(0, [0, 0])
    @coil_proxy[0..1] = [0, 0]
  end


  # Discrete input tests
  it "should call read_discrete_input" do
    @slave.should_receive(:read_discrete_input).with(0, 1)
    @discrete_input_proxy[0]
  end

  it "should call read_discrete_inputs" do
    @slave.should_receive(:read_discrete_inputs).with(0, 2)
    @discrete_input_proxy[0..1]
  end


  # Holding Register Tess
  it "should call read_holding_register" do
    @slave.should_receive(:read_holding_register).with(0, 1)
    @holding_register_proxy[0]
  end
  it "should call read_holding_registers" do
    @slave.should_receive(:read_holding_registers).with(0, 2)
    @holding_register_proxy[0..1]
  end
  it "should call write_holding_register" do
    @slave.should_receive(:write_holding_register).with(0, 1)
    @holding_register_proxy[0] = 1
  end
  it "should call write_holding_registers" do
    @slave.should_receive(:write_holding_registers).with(0, [0, 0])
    @holding_register_proxy[0..1] = [0, 0]
  end


  # Input Register Tests
  it "should call read_discrete_input" do
    @slave.should_receive(:read_input_register).with(0, 1)
    @input_register_proxy[0]
  end

  it "should call read_discrete_inputs" do
    @slave.should_receive(:read_input_registers).with(0, 2)
    @input_register_proxy[0..1]
  end
end

