# -*- coding: ascii
require 'rmodbus'

describe ModBus::RTUServer do
  before do
    @sp = double('SerialPort')
    expect(CCutrer::SerialPort).to receive(:new).with('/dev/ttyS0', baud: 4800, data_bits: 7, stop_bits: 2, parity: :none).and_return(@sp)

    @server = ModBus::RTUServer.new('/dev/ttyS0', 4800, :data_bits => 7, :stop_bits => 2)
    @slave = @server.with_slave(1)
    @slave.coils = [1,0,1,1]
    @slave.discrete_inputs = [1,1,0,0]
    @slave.holding_registers = [1,2,3,4]
    @slave.input_registers = [1,2,3,4]
  end

  it "should be valid initialized " do
    expect(@slave.coils).to eq([1,0,1,1])
    expect(@slave.discrete_inputs).to eq([1,1,0,0])
    expect(@slave.holding_registers).to eq([1,2,3,4])
    expect(@slave.input_registers).to eq([1,2,3,4])

    expect(@server.port).to eq('/dev/ttyS0')
    expect(@server.baud).to eq(4800)
    expect(@server.data_bits).to eq(7)
    expect(@server.stop_bits).to eq(2)
    expect(@server.parity).to eq(:none)
  end
end
