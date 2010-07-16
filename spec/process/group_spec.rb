begin
  require 'rubygems'
rescue
end
require 'rmodbus'

include ModBus::Process

describe Group do
  before do
    @grp = Group.new("grp")
  end

  it "should have name" do
    @grp.name.should == "grp"
  end

  it "should have children group" do
    @grp.add_group("grp_1")
	@grp.grp_1.class.should == Group
	@grp.grp_1.name.should == "grp_1"
  end

  it "should have points" do
    @grp.add_point("point_1")
	@grp.point_1.class.should == Point
	@grp.point_1.name.should == "point_1"
  end

  it "should have parent" do
    @grp.add_group("grp_1") 
    @grp.grp_1.parent.should == @grp
  end

end

