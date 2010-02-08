require 'rmodbus'

include ModBus

describe Client, "Get value" do
  before do
    @cl_mb = Client.new
  end

  it "should get value from coil" do
    @cl_mb.should_receive(:query).with("\x1\x0\x1\x0\x1").and_return("\x01")    
    @cl_mb.get_value(1).should == 1
  end

  it "should get value from discrete input" do
    @cl_mb.should_receive(:query).with("\x2\x0\x5\x0\x1").and_return("\x00")    
    @cl_mb.get_value(100005).should == 0
  end

  it "should get value from holding register" do
    @cl_mb.should_receive(:query).with("\x3\x0\x4\x0\x1").and_return("\x00\xaa")    
    @cl_mb.get_value(400004).should == 0x00aa
  end

  it "should get value from input register" do
    @cl_mb.should_receive(:query).with("\x4\x0\x4\x0\x1").and_return("\xcc\xaa")    
    @cl_mb.get_value(300004).should == 0xccaa
  end

  it "should raise exception if address notation not valid" do
    lambda { @cl_mb.get_value(500100) }.should raise_error(Errors::ModBusException)
  end

  #Float
  it "should get float value from holding register" do
    @cl_mb.should_receive(:query).with("\x3\x0\x4\x0\x2").and_return("\x3e\x40\x0\x0")    
    @cl_mb.get_value(400004, :type => :float).should == 0.1875
  end

  it "should get float value from input register" do
    @cl_mb.should_receive(:query).with("\x4\x0\x4\x0\x2").and_return("\x3e\x40\x0\x0")    
    @cl_mb.get_value(300004, :type => :float).should == 0.1875
  end

  #UInt32
  it "should get int32 value from holding register" do
    @cl_mb.should_receive(:query).with("\x3\x0\x4\x0\x2").and_return("\x3e\x40\x0\x0")    
    @cl_mb.get_value(400004, :type => :uint32).should == 0x3e400000
  end

  it "should get int32 value from input register" do
    @cl_mb.should_receive(:query).with("\x4\x0\x4\x0\x2").and_return("\x3e\x40\x0\x0")    
    @cl_mb.get_value(300004, :type => :uint32).should == 0x3e400000
  end

  #Double
  it "should get double value from holding register" do
    @cl_mb.should_receive(:query).with("\x3\x0\x4\x0\x4").and_return("\x40\x04\x0\x0\x0\x0\x0\x0")    
    @cl_mb.get_value(400004, :type => :double).should == 2.5 
  end

  it "should get double value from input register" do
    @cl_mb.should_receive(:query).with("\x4\x0\x4\x0\x4").and_return("\x40\x04\x0\x0\x0\x0\x0\x0")    
    @cl_mb.get_value(300004, :type => :double).should == 2.5
  end

end
