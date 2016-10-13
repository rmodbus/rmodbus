# -*- coding: ascii
require 'rmodbus'

describe Array do
  before do
    @arr = [1,0,1,1, 0,0,1,1, 1,1,0,1, 0,1,1,0,  1,0,1]
    @test = [0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]
  end

  it "should return string reprisent 16bit" do
    @arr.pack_to_word.should == "\xcd\x6b\x5" 
  end

  it "fixed bug for	divisible 8 data " do
    ([0] * 8).pack_to_word.should == "\x00"
  end
  
  it "should unpack to @test" do
    "test".unpack_bits == @test
  end

  it "should turn an array into 32b ints" do
    [20342, 17344].to_32i.should == [1136676726]
    [20342, 17344, 20342, 17344].to_32i.size.should == 2
  end

  it "should turn an array into 32b floats big endian" do
    [20342, 17344].to_32f[0].should be_within(0.1).of(384.620788574219)
    [20342, 17344, 20342, 17344].to_32f.size.should == 2
  end
  
  it "should turn a an array into 32b floats (little endian)" do
    [17344, 20342].to_32f_le[0].should be_within(0.1).of(384.620788574219)
    [17344, 20342, 17344, 20342].to_32f_le.size.should == 2
  end

  it "should turn an array from 32b ints into 16b ints, big endian" do
    [1136676726].from_32i.should == [20342, 17344]
    [1136676726, 1136676725].from_32i.should == [20342, 17344, 20341, 17344]
  end

  it "should turn an array from 32b floats into 16b ints, big endian" do
    [384.620788].from_32f.should == [20342, 17344]
    [384.620788, 384.620788].from_32f.should == [20342, 17344, 20342, 17344]
  end

  it "should raise exception if uneven number of elements" do
   lambda { [20342, 17344, 123].to_32f }.should raise_error(StandardError)
   lambda { [20342, 17344, 123].to_32i }.should raise_error(StandardError)
  end
end

