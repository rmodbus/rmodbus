require 'rmodbus'

include ModBus

describe RTUServer do
  before do
    @sp = mock "SerialPort"
    SerialPort.stub!(:new).and_return(@sp)
    @sp.stub!(:read_timeout=)

    @server = RTUServer.new('/dev/ttyS0')
    @server.coils = [1,0,1,1]
    @server.discrete_inputs = [1,1,0,0]
    @server.holding_registers = [1,2,3,4]
    @server.input_registers = [1,2,3,4]
  end

  it "should be valid initialized " do
    @server.coils.should == [1,0,1,1]
    @server.discrete_inputs.should == [1,1,0,0]
    @server.holding_registers.should == [1,2,3,4]
    @server.input_registers.should == [1,2,3,4]
  end

end
