include ModBus

describe Client do
  before do
    @cl = Client.new
  end

  it "should give object provider for slave" do
    slave = @cl.with_slave(1)
    slave.uid.should eq(1)
  end

  it "should give obeject provider for slave in block" do
    @cl.with_slave(1) do |slave|
      slave.uid.should eq(1)
    end
  end
end
