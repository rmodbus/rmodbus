# -*- coding: ascii
require 'rmodbus'

describe ModBus::RTUServer do
  before do
    @sp = double('SerialPort')
    SerialPort.should_receive(:new).with('/dev/ttyS0', 4800, 7, 2, SerialPort::NONE).and_return(@sp)
    @sp.stub(:read_timeout=)
    @sp.should_receive(:flow_control=).with(SerialPort::NONE)

    @server = ModBus::RTUServer.new('/dev/ttyS0', 4800, :data_bits => 7, :stop_bits => 2)
    @slave = @server.with_slave(1)
    @slave.coils = [1,0,1,1]
    @slave.discrete_inputs = [1,1,0,0]
    @slave.holding_registers = [1,2,3,4]
    @slave.input_registers = [1,2,3,4]
  end

  it "should be valid initialized " do
    @slave.coils.should == [1,0,1,1]
    @slave.discrete_inputs.should == [1,1,0,0]
    @slave.holding_registers.should == [1,2,3,4]
    @slave.input_registers.should == [1,2,3,4]

    @server.port.should == '/dev/ttyS0'
    @server.baud.should == 4800
    @server.data_bits.should == 7
    @server.stop_bits.should == 2
    @server.parity.should == SerialPort::NONE
  end
end
