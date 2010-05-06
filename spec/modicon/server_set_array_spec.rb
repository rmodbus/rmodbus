require 'rmodbus'

include ModBus

describe TCPServer, "Set value for array" do
  before do
    @srv = ModBus::TCPServer.new(8502,1)
    @srv.coils = [0] * 10
    @srv.discrete_inputs = [0] * 10
    @srv.holding_registers = [0] * 10
    @srv.input_registers = [0] * 10
  end

  it "should set 4 values from coils" do
    @srv.coils[0,4].should == [0,0,0,0]

    @srv.set_value(0, [1,0,1,0])
    @srv.coils[0,4].should == [1,0,1,0]
  end

  it "should set 3 values from holding registers" do
    @srv.holding_registers[0,3].should == [0] * 3

    @srv.set_value(400000, [0x4321, 0, 0x1234])
    @srv.holding_registers[0,3].should == [0x4321, 0,  0x1234]
  end

  #Float[]
  it "should set 2 float values from holding registers" do
    @srv.holding_registers[0,4].should == [0] * 4

    @srv.set_value(400000, [0.1875]* 2, :type => :float) 
    @srv.holding_registers[0,4].should == [0x3e40, 0, 0x3e40, 0]
  end

  #UInt32[]
  it "should set 2 uint32 values from holding registers" do
    @srv.holding_registers[0,4].should == [0] * 4
    
    @srv.set_value(400000, [0x3e400000]* 2, :type => :uint32) 
    @srv.holding_registers[0,4].should == [0x3e40, 0, 0x3e40, 0]
  end


  #Double[]
  it "should set 2 double value from holding registers" do
    @srv.holding_registers[0,8].should == [0] * 8
    @srv.set_value(400000,  [1.9] * 2, :type => :double)
    @srv.holding_registers[0,8].should == [16382, 26214, 26214, 26214] * 2 
  end

end
