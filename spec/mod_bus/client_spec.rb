# -*- coding: ascii
# frozen_string_literal: true

require "rmodbus"

describe ModBus::Client do
  before do
    @cl = ModBus::Client.new
  end

  it "gives object provider for slave" do
    slave = @cl.with_slave(1)
    expect(slave.uid).to eq(1)
  end

  it "gives object provider for slave in block" do
    @cl.with_slave(1) do |slave|
      expect(slave.uid).to eq(1)
    end
  end

  it "connects with TCP server" do
    ModBus::Client.connect do |cl|
      expect(cl).to be_instance_of(ModBus::Client)
    end
  end

  it ":new alias :connect" do
    ModBus::Client.new do |cl|
      expect(cl).to be_instance_of(ModBus::Client)
    end
  end

  it "closes the connection when an exception is raised in the given block" do
    e = RuntimeError.new
    expect do
      ModBus::Client.new do |client|
        expect(client).to receive(:close)
        raise e
      end
    end.to raise_error(e)
  end

  it "shares :debug flag with all slaves" do
    @cl.logger = true
    @cl.with_slave(1) do |slave1|
      expect(slave1.logger).to be true
    end
    @cl.with_slave(2) do |slave2|
      slave2.logger = false
      expect(slave2.logger).to be false
    end
  end

  it "shares :raise_exception_on_mismatch flag with all slaves" do
    @cl.raise_exception_on_mismatch = true
    @cl.with_slave(1) do |slave1|
      expect(slave1.raise_exception_on_mismatch).to be_truthy
    end

    @cl.with_slave(2) do |slave2|
      slave2.raise_exception_on_mismatch = false
      expect(slave2.raise_exception_on_mismatch).to be_falsey
    end
  end

  it "shares :read_retries option with all slaves" do
    @cl.read_retries = 5
    @cl.with_slave(1) do |slave1|
      expect(slave1.read_retries).to be(5)
    end

    @cl.with_slave(2) do |slave2|
      slave2.read_retries = 15
      expect(slave2.read_retries).to be(15)
    end
  end

  it "shares :read_retry_timeout option with all slaves" do
    @cl.read_retry_timeout = 5
    @cl.with_slave(1) do |slave1|
      expect(slave1.read_retry_timeout).to be(5)
    end

    @cl.with_slave(2) do |slave2|
      slave2.read_retry_timeout = 15
      expect(slave2.read_retry_timeout).to be(15)
    end
  end
end
