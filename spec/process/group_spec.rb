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
    grp_1 = Group.new("grp_1")

    @grp.add grp_1
	@grp.grp_1.should == grp_1
  end

  it "should have points" do
    point_1 = Point.new("point_1")

    @grp.add point_1
	@grp.point_1.should == point_1 
  end

  it "should have parent" do
    @grp.add Group.new("grp_1")
    @grp.grp_1.parent.should == @grp
  end

  it "should rename obj" do
    grp_1 = Group.new("grp_1")

    @grp.add grp_1
	@grp.grp_1.name = "grp"
	@grp.grp.should == grp_1
  end

end

