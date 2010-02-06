require 'rmodbus'

include ModBus

describe Client, "Set value" do
  before do
    @cl_mb = Client.new
  end

  it "should set value to single coil" do
    @cl_mb.should_receive(:query).with("\x5\x0\x1\xff\x00")    
    @cl_mb.set_value(1,1).should == @cl_mb
    @cl_mb.should_receive(:query).with("\x5\x0\x1\x00\x00")    
    @cl_mb.set_value(1,0).should == @cl_mb
  end

  it "should set value to single holding register" do
    @cl_mb.should_receive(:query).with("\x6\x0\x4\x00\xaa")
    @cl_mb.set_value(400004, 0x00aa).should == @cl_mb
  end

  it "should raise exception if address notation not valid" do
    lambda { @cl_mb.set_value(400100, 0) }.should raise_error(Errors::ModBusException)
  end

end
