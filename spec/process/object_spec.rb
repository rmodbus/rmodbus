begin
  require 'rubygems'
rescue
end
require 'rmodbus'

describe ModBus::Process::Object do
  it "shoild have unique id" do
    obj1 = ModBus::Process::Object.new("obj1")
    obj2 = ModBus::Process::Object.new("obj2")
	obj1.id.should_not == obj2.id
  end

  it "should have name" do
    obj1 = ModBus::Process::Object.new("obj1")
	obj1.name.should == "obj1"
  end
end

