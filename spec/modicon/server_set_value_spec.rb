require 'rmodbus'

describe TCPServer, "set_value" do
  before do
    @srv = ModBus::TCPServer.new(8502,1)
    @srv.coils = [0] * 10
    @srv.discrete_inputs = [0] * 10
    @srv.holding_registers = [0] * 10
    @srv.input_registers = [0] * 10
  end

  it "should set value coil" do
    @srv.coils[0].should == 0

    @srv.set_value(0,1).should == @srv 
    @srv.coils[0].should == 1 
  end

  it "should set value from holding registers" do
    @srv.holding_registers[0].should == 0

    @srv.set_value(400000,0x1234)
    @srv.holding_registers[0].should == 0x1234
  end

  it "should raise exception if address notation not valid" do
    lambda { @srv.set_value(100100, 1) }.should raise_error(Errors::ModBusException)
  end

  #Float
  it "should set float value from holding registers" do
    @srv.holding_registers[0,2].should == [0, 0]

    @srv.set_value(400000, 0.1875, :type => :float) 
    @srv.holding_registers[0,2].should == [0x3e40, 0]
  end

  #Double
  it "should set double value from holding registers" do
    @srv.holding_registers[0,4].should == [0] * 4

    @srv.set_value(400000, 1.9, :type => :double)
    @srv.holding_registers[0,4].should == [16382, 26214, 26214, 26214] 
  end

  #Uint32
  it "should set uint32 value from holding registers" do
    @srv.holding_registers[0,2].should == [0, 0] 

    @srv.set_value(400000, 0x10002, :type => :uint32)    
    @srv.holding_registers[0,2].should == [1, 2] 
  end

end
