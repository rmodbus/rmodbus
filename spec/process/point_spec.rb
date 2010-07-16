begin
  require 'rubygems'
rescue
end
require 'rmodbus'

include ModBus::Process

describe Point do
  before do
    @pt = Point.new("point_1")
  end

  it "should have name" do
    @pt.name.should == "point_1"
  end
  
  it "should have parent" do
    grp = Group.new("grp")
	grp.add Point.new("point")
	grp.point.parent.should == grp
  end

end
