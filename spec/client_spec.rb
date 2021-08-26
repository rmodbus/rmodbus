# -*- coding: ascii
require 'rmodbus'

describe ModBus::Client do
  before do
    @cl = ModBus::Client.new
  end

  it "should give object provider for slave" do
    slave = @cl.with_slave(1)
    slave.uid.should eq(1)
  end

  it "should give object provider for slave in block" do
    @cl.with_slave(1) do |slave|
      slave.uid.should eq(1)
    end
  end
  
  it "should connect with TCP server" do
    ModBus::Client.connect do |cl|
      cl.should be_instance_of(ModBus::Client)
    end
  end
  
  it ":new alias :connect" do
    ModBus::Client.new do |cl|
      cl.should be_instance_of(ModBus::Client)
    end
  end

  it "should close the connection when an exception is raised in the given block" do
    expect {
      ModBus::Client.new do |client|
        client.should_receive(:close)
        raise
      end
    }.to raise_error
  end

  it 'should common for all slaves :debug flag' do
    @cl.logger = true
    @cl.with_slave(1) do |slave_1|
      slave_1.logger.should eq true
    end
    @cl.with_slave(2) do |slave_2|
      slave_2.logger = false
      slave_2.logger.should eq false
    end
  end

  it 'should common for all slaves :raise_exception_on_mismatch flag' do
    @cl.raise_exception_on_mismatch = true
    @cl.with_slave(1) do |slave_1|
      slave_1.raise_exception_on_mismatch.should be_truthy
    end

    @cl.with_slave(2) do |slave_2|
      slave_2.raise_exception_on_mismatch = false
      slave_2.raise_exception_on_mismatch.should be_falsey
    end
  end
  
  it 'should common for all slaves :read_retries options' do
   @cl.read_retries = 5
    @cl.with_slave(1) do |slave_1|
      slave_1.read_retries.should eql(5)
    end

    @cl.with_slave(2) do |slave_2|
      slave_2.read_retries = 15
      slave_2.read_retries.should eql(15)
    end
  end

  it 'should common for all slaves :read_retry_timeout options' do
   @cl.read_retry_timeout = 5
    @cl.with_slave(1) do |slave_1|
      slave_1.read_retry_timeout.should eql(5)
    end

    @cl.with_slave(2) do |slave_2|
      slave_2.read_retry_timeout = 15
      slave_2.read_retry_timeout.should eql(15)
    end
  end

end
