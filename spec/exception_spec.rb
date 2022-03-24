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
    expect { @slave.holding_registers[0..2] = [0, 0] }.to raise_error(ModBus::Errors::ProxyException)
  end

  # Read coil status
  it "should read coil status" do
    expect(@slave.read_coils(0, 4)).to eq([0] * 4)
  end

  it "should raise exception if illegal data address" do
    expect { @slave.read_coils(501, 34) }.to raise_error(ModBus::Errors::IllegalDataAddress)
  end

  it "should raise exception if too many data" do
    expect { @slave.read_coils(0, 0x07D1) }.to raise_error(ModBus::Errors::IllegalDataValue)
  end

  # Read input status
  it "should read discrete inputs" do
    expect(@slave.read_discrete_inputs(0, 4)).to eq([0] * 4)
  end

  it "should raise exception if illegal data address" do
    expect { @slave.read_discrete_inputs(50, 23) }.to raise_error(ModBus::Errors::IllegalDataAddress)
  end

  it "should raise exception if too many data" do
    expect { @slave.read_discrete_inputs(0, 0x07D1) }.to raise_error(ModBus::Errors::IllegalDataValue)
  end

  # Read holding registers
  it "should read discrete inputs" do
    expect(@slave.read_holding_registers(0, 4)).to eq([0, 0, 0, 0])
  end

  it "should raise exception if illegal data address" do
    expect { @slave.read_holding_registers(402, 99) }.to raise_error(ModBus::Errors::IllegalDataAddress)
  end

  it "should raise exception if too many data" do
    expect { @slave.read_holding_registers(0, 0x007E) }.to raise_error(ModBus::Errors::IllegalDataValue)
  end

  # Read input registers
  it "should read discrete inputs" do
    expect(@slave.read_input_registers(0, 4)).to eq([0, 0, 0, 0])
  end

  it "should raise exception if illegal data address" do
    expect { @slave.read_input_registers(402, 9) }.to raise_error(ModBus::Errors::IllegalDataAddress)
  end

  it "should raise exception if too many data" do
    expect { @slave.read_input_registers(0, 0x007E) }.to raise_error(ModBus::Errors::IllegalDataValue)
  end

  # Force single coil
  it "should force single coil" do
    expect(@slave.write_single_coil(4, 1)).to eq(@slave)
    expect(@slave.read_coils(4, 4)).to eq([1, 0, 0, 0])
  end

  it "should raise exception if illegal data address" do
    expect { @slave.write_single_coil(501, true) }.to raise_error(ModBus::Errors::IllegalDataAddress)
  end

  # Preset single register
  it "should preset single register" do
    expect(@slave.write_single_register(4, 0x0AA0)).to eq(@slave)
    expect(@slave.read_holding_registers(4, 1)).to eq([0x0AA0])
  end

  it "should raise exception if illegal data address" do
    expect { @slave.write_single_register(501, 0x0AA0) }.to raise_error(ModBus::Errors::IllegalDataAddress)
  end

  # Force multiple coils
  it "should force multiple coils" do
    expect(@slave.write_multiple_coils(4, [0, 1, 0, 1])).to eq(@slave)
    expect(@slave.read_coils(3, 5)).to eq([0, 0, 1, 0, 1])
  end

  it "should raise exception if illegal data address" do
    expect { @slave.write_multiple_coils(501, [1, 0]) }.to raise_error(ModBus::Errors::IllegalDataAddress)
  end

  # Preset multiple registers
  it "should preset multiple registers" do
    expect(@slave.write_multiple_registers(4, [1, 2, 3, 0xAACC])).to eq(@slave)
    expect(@slave.read_holding_registers(3, 5)).to eq([0, 1, 2, 3, 0xAACC])
  end

  it "should raise exception if illegal data address" do
    expect { @slave.write_multiple_registers(501, [1, 2]) }.to raise_error(ModBus::Errors::IllegalDataAddress)
  end

  after(:all) do
    @cl.close unless @cl.closed?
    @srv.stop
  end
end
