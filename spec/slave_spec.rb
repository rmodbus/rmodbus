# -*- coding: ascii
require 'rmodbus'

describe ModBus::Client::Slave do
  before do
    @slave = ModBus::Client.new.with_slave(1)

    @slave.stub(:query).and_return('')
  end

  it "should support function 'read coils'" do
    @slave.should_receive(:query).with("\x1\x0\x13\x0\x13").and_return("\xcd\x6b\x5")    
    @slave.read_coils(0x13,0x13).should == [1,0,1,1, 0,0,1,1, 1,1,0,1, 0,1,1,0,  1,0,1]
  end

  it "should support function 'read discrete inputs'" do
    @slave.should_receive(:query).with("\x2\x0\xc4\x0\x16").and_return("\xac\xdb\x35")    
    @slave.read_discrete_inputs(0xc4,0x16).should == [0,0,1,1, 0,1,0,1, 1,1,0,1, 1,0,1,1, 1,0,1,0, 1,1]
  end

  it "should support function 'read holding registers'" do
    @slave.should_receive(:query).with("\x3\x0\x6b\x0\x3").and_return("\x2\x2b\x0\x0\x0\x64")    
    @slave.read_holding_registers(0x6b,0x3).should == [0x022b, 0x0000, 0x0064]
  end

  it "should support function 'read input registers'" do
    @slave.should_receive(:query).with("\x4\x0\x8\x0\x1").and_return("\x0\xa")    
    @slave.read_input_registers(0x8,0x1).should == [0x000a]
  end

  it "should support function 'write single coil'" do
    @slave.should_receive(:query).with("\x5\x0\xac\xff\x0").and_return("\xac\xff\x00")    
    @slave.write_single_coil(0xac,0x1).should == @slave
  end

  it "should support function 'write single register'" do
    @slave.should_receive(:query).with("\x6\x0\x1\x0\x3").and_return("\x1\x0\x3")    
    @slave.write_single_register(0x1,0x3).should == @slave
  end

  it "should support function 'write multiple coils'" do
    @slave.should_receive(:query).with("\xf\x0\x13\x0\xa\x2\xcd\x1").and_return("\x13\x0\xa")    
    @slave.write_multiple_coils(0x13,[1,0,1,1, 0,0,1,1, 1,0]).should == @slave
  end

  it "should support function 'write multiple registers'" do
    @slave.should_receive(:query).with("\x10\x0\x1\x0\x3\x6\x0\xa\x1\x2\xf\xf").and_return("\x1\x0\x3")    
    @slave.write_multiple_registers(0x1,[0x000a,0x0102, 0xf0f]).should == @slave
  end

  it "should support function 'mask write register'" do
    @slave.should_receive(:query).with("\x16\x0\x4\x0\xf2\x0\2").and_return("\x4\x0\xf2\x0\x2")
    @slave.mask_write_register(0x4, 0xf2, 0x2).should == @slave
  end
end
