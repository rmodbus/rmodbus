begin
  require 'rubygems'
rescue
end
require 'rmodbus'

include ModBus::Process

describe Point do
  before do
    @scanner = Scanner.new("scanner")
    @pt = Point.new("point_1", :type => :int32, :scanner => @scanner, :offset => 0)
  end

  it "should have name" do
    @pt.name.should == "point_1"
  end
  
  it "should have parent" do
    grp = Group.new("grp")
	grp.add Point.new("point")
	grp.point.parent.should == grp
  end

  it "should have value" do
    @pt.value.should == nil 
  end

  it "should have type" do
    @pt.type.should == :int32
  end

  it "should have timestamp" do
	@pt.timestamp.class.should == Time
  end

  it "should have scanner" do
    @pt.scanner.should == @scanner
  end

  it "should have offset" do
    @pt.offset.should == 0
  end

end
