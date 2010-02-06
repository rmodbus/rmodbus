require 'rmodbus'

include ModBus

describe Client, "Get value for array" do
  before do
    @cl_mb = Client.new
  end

  it "should get 4 values from coils" do
    @cl_mb.should_receive(:query).with("\x1\x0\x1\x0\x4").and_return("\x05")    
    @cl_mb.get_value(1, :number => 4).should == [1,0,1,0]
  end

  it "should get 8 values from discrete inputs" do
    @cl_mb.should_receive(:query).with("\x2\x0\x5\x0\x8").and_return("\xAA")    
    @cl_mb.get_value(100005, :number => 8).should == [0,1,0,1,0,1,0,1]
  end

  it "should get 2 values from holding registers" do
    @cl_mb.should_receive(:query).with("\x3\x0\x4\x0\x2").and_return("\x00\xaa\x11\x22")    
    @cl_mb.get_value(400004, :number => 2).should == [0x00aa, 0x1122]
  end

  it "should get 3 values from input registers" do
    @cl_mb.should_receive(:query).with("\x4\x0\x4\x0\x3").and_return("\xcc\xaa\x1\x2\x0\x0")    
    @cl_mb.get_value(300004, :number => 3).should == [0xccaa, 0x0102, 0]
  end

  #Float[]
  it "should get 2 float values from holding registers" do
    @cl_mb.should_receive(:query).with("\x3\x0\x4\x0\x4").and_return("\x3e\x40\x0\x0\x3e\x40\x0\x0")    
    @cl_mb.get_value(400004, :type => :float, :number => 2).should == [0.1875, 0.1875]
  end

  it "should get 2 floats value from input registers" do
    @cl_mb.should_receive(:query).with("\x4\x0\x4\x0\x4").and_return("\x3e\x40\x0\x0\x3e\x40\x0\x0")    
    @cl_mb.get_value(300004, :type => :float, :number => 2).should == [0.1875, 0.1875]
  end

  #UInt32[]
  it "should get 2 int32 values from holding registers" do
    @cl_mb.should_receive(:query).with("\x3\x0\x4\x0\x4").and_return("\x3e\x40\x0\x0\x1\x2\x3\x4")    
    @cl_mb.get_value(400004, :type => :uint32, :number => 2).should == [0x3e400000, 0x01020304]
  end

  it "should get 2 int32 values from input registers" do
     @cl_mb.should_receive(:query).with("\x4\x0\x4\x0\x4").and_return("\x3e\x40\x0\x0\x1\x2\x3\x4")    
    @cl_mb.get_value(300004, :type => :uint32, :number => 2).should == [0x3e400000, 0x01020304]
  end

  #Double[]
  it "should get double value from holding register" do
    @cl_mb.should_receive(:query).with("\x3\x0\x4\x0\x8").and_return("\x40\x04\x0\x0\x0\x0\x0\x0\x40\x04\x0\x0\x0\x0\x0\x0")    
    @cl_mb.get_value(400004, :type => :double, :number => 2).should == [2.5, 2.5]
  end

  it "should get double value from input register" do
    @cl_mb.should_receive(:query).with("\x4\x0\x4\x0\x8").and_return("\x40\x04\x0\x0\x0\x0\x0\x0\x40\x04\x0\x0\x0\x0\x0\x0")    
    @cl_mb.get_value(300004, :type => :double, :number => 2).should == [2.5, 2.5]
  end

end
