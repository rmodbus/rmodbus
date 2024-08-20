# -*- coding: ascii
# frozen_string_literal: true

# RuboCop doesn't think singular vs. plural differs
# rubocop:disable RSpec/RepeatedDescription
describe ModBus::ReadOnlyProxy do
  before do
    @slave = instance_double(ModBus::Client::Slave)
    @coil_proxy = ModBus::ReadWriteProxy.new(@slave, :coil)
    @discrete_input_proxy = ModBus::ReadOnlyProxy.new(@slave, :discrete_input)
    @holding_register_proxy = ModBus::ReadWriteProxy.new(@slave, :holding_register)
    @input_register_proxy = ModBus::ReadOnlyProxy.new(@slave, :input_register)
  end

  # Handle all of the coil methods
  it "calls read_coil" do
    expect(@slave).to receive(:read_coil).with(0)
    @coil_proxy[0]
  end

  it "calls read_coils" do
    expect(@slave).to receive(:read_coils).with(0, 2)
    @coil_proxy[0..1]
  end

  it "calls write_coil" do
    expect(@slave).to receive(:write_coil).with(0, 1)
    @coil_proxy[0] = 1
  end

  it "calls write_coils" do
    expect(@slave).to receive(:write_coils).with(0, [0, 0])
    @coil_proxy[0..1] = [0, 0]
  end

  # Discrete input tests
  it "calls read_discrete_input" do
    expect(@slave).to receive(:read_discrete_input).with(0)
    @discrete_input_proxy[0]
  end

  it "calls read_discrete_inputs" do
    expect(@slave).to receive(:read_discrete_inputs).with(0, 2)
    @discrete_input_proxy[0..1]
  end

  # Holding Register Tess
  it "calls read_holding_register" do
    expect(@slave).to receive(:read_holding_register).with(0)
    @holding_register_proxy[0]
  end

  it "calls read_holding_registers" do
    expect(@slave).to receive(:read_holding_registers).with(0, 2)
    @holding_register_proxy[0..1]
  end

  it "calls write_holding_register" do
    expect(@slave).to receive(:write_holding_register).with(0, 1)
    @holding_register_proxy[0] = 1
  end

  it "calls write_holding_registers" do
    expect(@slave).to receive(:write_holding_registers).with(0, [0, 0])
    @holding_register_proxy[0..1] = [0, 0]
  end

  # Input Register Tests
  it "calls read_discrete_input" do
    expect(@slave).to receive(:read_input_register).with(0)
    @input_register_proxy[0]
  end

  it "calls read_discrete_inputs" do
    expect(@slave).to receive(:read_input_registers).with(0, 2)
    @input_register_proxy[0..1]
  end
end
# rubocop:enable RSpec/RepeatedDescription
