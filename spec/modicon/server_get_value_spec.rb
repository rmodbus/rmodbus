require 'rmodbus'

describe TCPServer, "get_value" do
  before do
    @srv = ModBus::TCPServer.new(8502,1)
    @srv.coils = [0] * 10
    @srv.discrete_inputs = [0] * 10
    @srv.holding_registers = [0] * 10
    @srv.input_registers = [0] * 10
  end

  it "should get value coil" do
    @srv.get_value(0).should == 0

    @srv.coils[0] = 1
    @srv.get_value(0).should == 1 
  end

  it "should get value from discrete inputs" do
    @srv.get_value(100000).should == 0

    @srv.discrete_inputs[0] = 1
    @srv.get_value(100000).should == 1 
  end

  it "should get value from input registers" do
    @srv.get_value(300000).should == 0

    @srv.input_registers[0] = 0x4321
    @srv.get_value(300000).should == 0x4321 
  end

  it "should get value from holding registers" do
    @srv.get_value(400000).should == 0

    @srv.holding_registers[0] = 0x1234
    @srv.get_value(400000).should == 0x1234 
  end

  it "should raise exception if address notation not valid" do
    lambda { @srv.get_value(500100) }.should raise_error(Errors::ModBusException)
  end

  #Float
  it "should get float value from holding registers" do
    @srv.holding_registers[0,2] = [0x3e40, 0]
    @srv.get_value(400000, :type => :float).should == 0.1875 
  end

  it "should get float value from input registers" do
    @srv.input_registers[0,2] = [0x3e40, 0]
    @srv.get_value(300000, :type => :float).should == 0.1875 
  end

  #Double
  it "should get double value from holding registers" do
    @srv.holding_registers[0,4] = [16382, 26214, 26214, 26214] 
    @srv.get_value(400000, :type => :double).should == 1.9
  end

  it "should get double value from input registers" do
    @srv.input_registers[0,4] = [16382, 26214, 26214, 26214]
    @srv.get_value(300000, :type => :double).should == 1.9 
  end

  #Uint32
  it "should get uint32 value from holding registers" do
    @srv.holding_registers[0,2] = [1, 2] 
    @srv.get_value(400000, :type => :uint32).should == 0x10002
  end

  it "should get uint32 value from input registers" do
    @srv.input_registers[0,2] = [4, 3]
    @srv.get_value(300000, :type => :uint32).should == 0x40003 
  end

end
