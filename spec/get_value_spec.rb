require 'rmodbus'

include ModBus

describe Client, "Get value" do
  before do
    @cl_mb = Client.new
    @cl_mb.stub!(:query).and_return('')
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
    @cl_mb.get_value(300004).should == 0x00aa
  end

  it "should get value from input register" do
    @cl_mb.should_receive(:query).with("\x4\x0\x4\x0\x1").and_return("\xcc\xaa")    
    @cl_mb.get_value(400004).should == 0xccaa
  end

  it "should raise exception if address notation not valid" do
    lambda { @cl_mb.get_value(500100) }.should raise_error(Errors::ModBusException)
  end


end
