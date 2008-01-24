require 'rmodbus/client'

include ModBus

describe Client do

  before do
    @cl_mb = Client.new
    @cl_mb.stub!(:query).and_return('')
  end

  it "should support function 'read coils'" do
    @cl_mb.should_receive(:query).with("\x1\x0\x13\x0\x13").and_return("\xcd\x6b\x5")    
    @cl_mb.read_coils(0x13,0x13).should == [1,0,1,1, 0,0,1,1, 1,1,0,1, 0,1,1,0,  1,0,1]
  end

  it "should support function 'read discrete inputs'" do
    @cl_mb.should_receive(:query).with("\x2\x0\xc4\x0\x16").and_return("\xac\xdb\x35")    
    @cl_mb.read_discret_inputs(0xc4,0x16).should == [0,0,1,1, 0,1,0,1, 1,1,0,1, 1,0,1,1, 1,0,1,0, 1,1]
  end

  it "should support function 'read holding registers'" do
    @cl_mb.should_receive(:query).with("\x3\x0\x6b\x0\x3").and_return("\x2\x2b\x0\x0\x0\x64")    
    @cl_mb.read_holding_registers(0x6b,0x3).should == [0x022b, 0x0000, 0x0064]
  end

  it "should support function 'read input registers'" do
    @cl_mb.should_receive(:query).with("\x4\x0\x8\x0\x1").and_return("\x0\xa")    
    @cl_mb.read_input_registers(0x8,0x1).should == [0x000a]
  end

  it "should support function 'write single coil'" do
    @cl_mb.should_receive(:query).with("\x5\x0\xac\xff\x0").and_return("\xac\xff\x00")    
    @cl_mb.write_single_coil(0xac,0x1).should == @cl_mb
  end

  it "should support function 'write single register'" do
    @cl_mb.should_receive(:query).with("\x6\x0\x1\x0\x3").and_return("\x1\x0\x3")    
    @cl_mb.write_single_register(0x1,0x3).should == @cl_mb
  end

  it "should support function 'write multiple coils'" do
    @cl_mb.should_receive(:query).with("\xf\x0\x13\x0\xa\x2\xcd\x1").and_return("\x13\x0\xa")    
    @cl_mb.write_multiple_coils(0x13,[1,0,1,1, 0,0,1,1, 1,0]).should == @cl_mb
  end

  it "should support function 'write multiple registers'" do
    @cl_mb.should_receive(:query).with("\x10\x0\x1\x0\x2\x4\x0\xa\x1\x2").and_return("\x1\x0\x2")    
    @cl_mb.write_multiple_registers(0x1,[0x000a,0x0102]).should == @cl_mb
  end

  it "should support function 'mask write register'" do
    @cl_mb.should_receive(:query).with("\x16\x0\x4\x0\xf2\x0\2").and_return("\x4\x0\xf2\x0\x2")
    @cl_mb.mask_write_register(0x4, 0xf2, 0x2).should == @cl_mb
  end

end
