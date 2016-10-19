# -*- coding: ascii
require 'rmodbus'

describe ModBus::Array do
  it "should accept endianness when converting to 32b values" do
    lambda { ModBus::Array.new([20342, 17344]).to_32i(:big) }.should_not raise_error
    lambda { ModBus::Array.new([20342, 17344]).to_32i(:little) }.should_not raise_error
    lambda { ModBus::Array.new([20342, 17344]).to_32i(:foo) }.should raise_error(StandardError)
  end

  it "should turn an array into 32b ints, big endian" do
    ModBus::Array.new([20342, 17344]).to_32i(:big).should == [1136676726]
    ModBus::Array.new([20342, 17344, 20342, 17344]).to_32i(:big).size.should == 2
  end

  it "should turn an array into 32b floats, big endian" do
    ModBus::Array.new([20342, 17344]).to_32f(:big)[0].should be_within(0.1).of(384.620788574219)
    ModBus::Array.new([20342, 17344, 20342, 17344]).to_32f(:big).size.should == 2
  end

  it "should turn an array into 32b ints, little endian" do
    ModBus::Array.new([17344, 20342]).to_32i(:little).should == [1136676726]
    ModBus::Array.new([17344, 20342, 17344, 20342]).to_32i(:little).size.should == 2
  end

  it "should turn an array into 32b floats, big endian" do
    ModBus::Array.new([17344, 20342]).to_32f(:little)[0].should be_within(0.1).of(384.620788574219)
    ModBus::Array.new([17344, 20342, 17344, 20342]).to_32f(:little).size.should == 2
  end

  it "should turn an array from 32b ints into 16b ints, big endian" do
    ModBus::Array.new([1136676726]).from_32i(:big).should == [20342, 17344]
    ModBus::Array.new([1136676726, 1136676725]).from_32i(:big).should == [20342, 17344, 20341, 17344]
  end

  it "should turn an array from 32b floats into 16b ints, big endian" do
    ModBus::Array.new([384.620788]).from_32f(:big).should == [20342, 17344]
    ModBus::Array.new([384.620788, 384.620788]).from_32f(:big).should == [20342, 17344, 20342, 17344]
  end

  it "should turn an array from 32b ints into 16b ints, little endian" do
    ModBus::Array.new([1136676726]).from_32i(:little).should == [17344, 20342]
    ModBus::Array.new([1136676726, 1136676725]).from_32i(:little).should == [17344, 20342, 17344, 20341]
  end

  it "should turn an array from 32b floats into 16b ints, little endian" do
    ModBus::Array.new([384.620788]).from_32f(:little).should == [17344, 20342]
    ModBus::Array.new([384.620788, 384.620788]).from_32f(:little).should == [17344, 20342, 17344, 20342]
  end

  it "should raise exception if uneven number of elements" do
   lambda { ModBus::Array.new([20342, 17344, 123]).to_32f }.should raise_error(StandardError)
   lambda { ModBus::Array.new([20342, 17344, 123]).to_32i }.should raise_error(StandardError)
  end
end
