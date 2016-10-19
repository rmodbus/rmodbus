# -*- coding: ascii
require 'rmodbus'

describe ModBus::Array do
  it "should turn an array into 32b ints" do
    ModBus::Array.new([20342, 17344]).to_32i.should == [1136676726]
    ModBus::Array.new([20342, 17344, 20342, 17344]).to_32i.size.should == 2
  end

  it "should turn an array into 32b floats, big endian" do
    ModBus::Array.new([20342, 17344]).to_32f[0].should be_within(0.1).of(384.620788574219)
    ModBus::Array.new([20342, 17344, 20342, 17344]).to_32f.size.should == 2
  end

  it "should turn an array from 32b ints into 16b ints, big endian" do
    ModBus::Array.new([1136676726]).from_32i.should == [20342, 17344]
    ModBus::Array.new([1136676726, 1136676725]).from_32i.should == [20342, 17344, 20341, 17344]
  end

  it "should turn an array from 32b floats into 16b ints, big endian" do
    ModBus::Array.new([384.620788]).from_32f.should == [20342, 17344]
    ModBus::Array.new([384.620788, 384.620788]).from_32f.should == [20342, 17344, 20342, 17344]
  end

  it "should raise exception if uneven number of elements" do
   lambda { ModBus::Array.new([20342, 17344, 123]).to_32f }.should raise_error(StandardError)
   lambda { ModBus::Array.new([20342, 17344, 123]).to_32i }.should raise_error(StandardError)
  end
end
