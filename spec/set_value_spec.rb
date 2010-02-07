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
    lambda { @cl_mb.set_value(300100, 0) }.should raise_error(Errors::ModBusException)
    lambda { @cl_mb.set_value(100100, 0) }.should raise_error(Errors::ModBusException)
  end

  #Uint32 
  it "should set uint value to holding registers" do
    @cl_mb.should_receive(:query).with("\x10\x0\x4\x0\x2\x4\x1\x2\x3\x4")  
    @cl_mb.set_value(400004, 0x01020304, :type => :uint32).should == @cl_mb
  end

  #Float
  it "should set float value to holding registers" do
    @cl_mb.should_receive(:query).with("\x10\x0\x4\x0\x2\x4?\360\x0\x0")  
    @cl_mb.set_value(400004, 1.875, :type => :float).should == @cl_mb
  end

  #Double 
  it "should set double value to holding registers" do
    @cl_mb.should_receive(:query).with("\x10\x0\x4\x0\x4\x8\x40\x04\x0\x0\x0\x0\x0\x0")  
    @cl_mb.set_value(400004, 2.5, :type => :double).should == @cl_mb
  end
end
