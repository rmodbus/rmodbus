require 'rmodbus'

include ModBus

describe Client, "Set value" do
  before do
    @cl_mb = Client.new
  end

  it "should set values to coils" do
    @cl_mb.should_receive(:query).with("\xf\x0\x13\x0\xa\x2\xcd\x1")    
    @cl_mb.set_value(0x13,[1,0,1,1, 0,0,1,1, 1,0]).should == @cl_mb
  end

  it "should set values to holding registers" do
    @cl_mb.should_receive(:query).with("\x10\x0\x1\x0\x3\x6\x0\xa\x1\x2\xf\xf")   
    @cl_mb.set_value(400001,[0x000a,0x0102, 0xf0f]).should == @cl_mb
  end

  #Uint32[]
  it "should set uint32 values to holding registers" do
    @cl_mb.should_receive(:query).with("\x10\x0\x4\x0\x4\x8\x1\x2\x3\x4\x5\x6\x7\x8")  
    @cl_mb.set_value(400004, [0x01020304, 0x05060708], :type => :uint32).should == @cl_mb
  end

  #Float[]
  it "should set floats values to holding registers" do
    @cl_mb.should_receive(:query).with("\x10\x0\x4\x0\x4\x8?\360\x0\x0?\360\x0\x0")  
    @cl_mb.set_value(400004, [1.875, 1.875], :type => :float).should == @cl_mb
  end

  #Double[] 
  it "should set double value to holding registers" do
    @cl_mb.should_receive(:query).with("\x10\x0\x4\x0\x8\x10\x40\x04\x0\x0\x0\x0\x0\x0\x40\x04\x0\x0\x0\x0\x0\x0")  
    @cl_mb.set_value(400004, [2.5, 2.5], :type => :double).should == @cl_mb
  end
end
