require 'rmodbus'

include ModBus

describe TCPServer, "Get value for array" do
  before do
    @srv = ModBus::TCPServer.new(8502,1)
    @srv.coils = [0] * 10
    @srv.discrete_inputs = [0] * 10
    @srv.holding_registers = [0] * 10
    @srv.input_registers = [0] * 10
  end

  it "should get 4 values from coils" do
    @srv.get_value(100000, :number => 4).should == [0,0,0,0]

    @srv.discrete_inputs[0,4] = [1,0,1,0]
    @srv.get_value(100000, :number => 4).should == [1,0,1,0]
  end

  it "should get 8 values from discrete inputs" do
    @srv.get_value(100000, :number => 8).should == [0,0,0,0,0,0,0,0]

    @srv.discrete_inputs[0,8] = [0,1,0,1,0,1,0,1]
    @srv.get_value(100000, :number => 8).should == [0,1,0,1,0,1,0,1]
  end

  it "should get 2 values from input registers" do
    @srv.get_value(300000, :number => 2).should == [0,0]

    @srv.input_registers[0,2] = [0x4321, 0x1234]
    @srv.get_value(300000, :number => 2).should == [0x4321, 0x1234]
  end

  it "should get 3 values from holding registers" do
    @srv.get_value(400000, :number => 3).should == [0,0,0]

    @srv.holding_registers[0,3] = [0x4321, 0,  0x1234]
    @srv.get_value(400000, :number => 3).should == [0x4321, 0, 0x1234]
  end

  #Float[]
  it "should get 2 floats value from input registers" do
    @srv.input_registers[0,4] = [0x3e40, 0, 0x3e40, 0]
    @srv.get_value(300000, :type => :float, :number => 2).should == [0.1875]* 2 
  end

  it "should get 2 float values from holding registers" do
    @srv.holding_registers[0,4] = [0x3e40, 0, 0x3e40, 0]
    @srv.get_value(400000, :type => :float, :number => 2).should == [0.1875]* 2 
  end

  #UInt32[]
  it "should get 2 uint32 values from input registers" do
    @srv.get_value(300000, :type => :uint32, :number => 2).should == [0]* 2 
    @srv.input_registers[0,4] = [0x3e40, 0, 0x3e40, 0]
    @srv.get_value(300000, :type => :uint32, :number => 2).should == [0x3e400000]* 2 
  end

  it "should get 2 uint32 values from holding registers" do
    @srv.get_value(400000, :type => :uint32, :number => 2).should == [0]* 2 
    @srv.holding_registers[0,4] = [0x3e40, 0, 0x3e40, 0]
    @srv.get_value(400000, :type => :uint32, :number => 2).should == [0x3e400000]* 2 
  end


  #Double
  it "should get double value from input registers" do
    @srv.input_registers[0,8] = [16382, 26214, 26214, 26214] * 2
    @srv.get_value(300000, :type => :double, :number => 2).should == [1.9] * 2
  end

  it "should get double value from holding registers" do
    @srv.holding_registers[0,8] = [16382, 26214, 26214, 26214] * 2 
    @srv.get_value(400000, :type => :double,  :number => 2).should == [1.9] * 2
  end

end
