# -*- coding: ascii

require 'rmodbus'

describe ModBus::Client do
  before do
    @cl = ModBus::Client.new
  end

  it "should give object provider for slave" do
    slave = @cl.with_slave(1)
    expect(slave.uid).to eq(1)
  end

  it "should give object provider for slave in block" do
    @cl.with_slave(1) do |slave|
      expect(slave.uid).to eq(1)
    end
  end

  it "should connect with TCP server" do
    ModBus::Client.connect do |cl|
      expect(cl).to be_instance_of(ModBus::Client)
    end
  end

  it ":new alias :connect" do
    ModBus::Client.new do |cl|
      expect(cl).to be_instance_of(ModBus::Client)
    end
  end

  it "should close the connection when an exception is raised in the given block" do
    expect {
      ModBus::Client.new do |client|
        expect(client).to receive(:close)
        raise
      end
    }.to raise_error
  end

  it 'should common for all slaves :debug flag' do
    @cl.logger = true
    @cl.with_slave(1) do |slave_1|
      expect(slave_1.logger).to eq true
    end
    @cl.with_slave(2) do |slave_2|
      slave_2.logger = false
      expect(slave_2.logger).to eq false
    end
  end

  it 'should common for all slaves :raise_exception_on_mismatch flag' do
    @cl.raise_exception_on_mismatch = true
    @cl.with_slave(1) do |slave_1|
      expect(slave_1.raise_exception_on_mismatch).to be_truthy
    end

    @cl.with_slave(2) do |slave_2|
      slave_2.raise_exception_on_mismatch = false
      expect(slave_2.raise_exception_on_mismatch).to be_falsey
    end
  end

  it 'should common for all slaves :read_retries options' do
    @cl.read_retries = 5
    @cl.with_slave(1) do |slave_1|
      expect(slave_1.read_retries).to eql(5)
    end

    @cl.with_slave(2) do |slave_2|
      slave_2.read_retries = 15
      expect(slave_2.read_retries).to eql(15)
    end
  end

  it 'should common for all slaves :read_retry_timeout options' do
    @cl.read_retry_timeout = 5
    @cl.with_slave(1) do |slave_1|
      expect(slave_1.read_retry_timeout).to eql(5)
    end

    @cl.with_slave(2) do |slave_2|
      slave_2.read_retry_timeout = 15
      expect(slave_2.read_retry_timeout).to eql(15)
    end
  end
end
