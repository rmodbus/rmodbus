# -*- coding: ascii
require "spec_helper"

describe "response mismach" do
  include RaiseResponseMatcher
  before(:each) do
    @slave = ModBus::Client::Slave.new(1, nil)
    @slave.raise_exception_on_mismatch = true
  end

  it "should raise error if function code is mismatch" do
    request = "\x1\x0\x13\x0\x12"
    response = "\x2\x3\xcd\xb6\x5"
    mock_query!(request, response)

    lambda{ @slave.read_coils(0x13,0x12) }.should raise_response_mismatch(
      "Function code is mismatch (expected 1, got 2)",
      request, response)
  end

  describe "read coils" do
    it "should raise error if count of byte is mismatch" do
      request = "\x1\x0\x13\x0\x12"
      response = "\x1\x2\xcd\xb6"
      mock_query!(request, response)

      lambda{ @slave.read_coils(0x13,0x12) }.should raise_response_mismatch(
        "Byte count is mismatch (expected 3, got 2 bytes)",
        request, response)
    end
  end

  describe "read discrete inputs" do
    it "should raise error if count of byte is mismatch" do
      request = "\x2\x0\x13\x0\x12"
      response = "\x2\x2\xcd\xb6"
      mock_query!(request, response)

      lambda{ @slave.read_discrete_inputs(0x13,0x12) }.should raise_response_mismatch(
        "Byte count is mismatch (expected 3, got 2 bytes)",
        request, response)
    end
  end

  describe "read holding registesrs" do
    it "should raise error if count of registers is mismatch" do
      request = "\x3\x0\x8\x0\x1"
      response = "\x3\x4\x0\xa\x0\xb"
      mock_query!(request, response)

      lambda{ @slave.read_holding_registers(0x8,0x1) }.should raise_response_mismatch(
        "Register count is mismatch (expected 1, got 2 regs)",
        request, response)
    end
  end

  describe "read input registesrs" do
    it "should raise error if count of registers is mismatch" do
      request = "\x4\x0\x8\x0\x2"
      response = "\x4\x2\xa\x0"
      mock_query!(request, response)

      lambda{ @slave.read_input_registers(0x8,0x2) }.should raise_response_mismatch(
        "Register count is mismatch (expected 2, got 1 regs)",
        request, response)
    end
  end

  describe "write single coil" do
    it "should raise error if address of coil is mismatch" do
      request = "\x5\x0\x8\xff\x0"
      response = "\x5\x0\x9\xff\x0"
      mock_query!(request, response)

      lambda{ @slave.write_coil(8,true) }.should raise_response_mismatch(
        "Address is mismatch (expected 8, got 9)",
        request, response)
    end

    it "should raise error if value of coil is mismatch" do
      request = "\x5\x0\x8\xff\x0"
      response = "\x5\x0\x8\x0\x0"
      mock_query!(request, response)

      lambda{ @slave.write_coil(8,true) }.should raise_response_mismatch(
        "Value is mismatch (expected 0xff00, got 0x0)",
        request, response)
    end
  end

  describe "write single register" do
    it "should raise error if address of register is mismatch" do
      request = "\x6\x0\x8\xa\xb"
      response = "\x6\x0\x9\xa\xb"
      mock_query!(request, response)

      lambda{ @slave.write_single_register(8,0x0a0b) }.should raise_response_mismatch(
        "Address is mismatch (expected 8, got 9)",
        request, response)
    end

    it "should raise error if value of register is mismatch" do
      request = "\x6\x0\x8\xa\xb"
      response = "\x6\x0\x8\x9\xb"
      mock_query!(request, response)

      lambda{ @slave.write_single_register(8,0x0a0b) }.should raise_response_mismatch(
        "Value is mismatch (expected 0xa0b, got 0x90b)",
        request, response)
    end
  end

  describe "write multiple coils" do
    it "should raise error if address of first coil is mismatch" do
      request = "\xf\x0\x13\x0\xa\2\xcd\x01"
      response = "\xf\x0\x14\x0\xa"
      mock_query!(request, response)

      lambda{ @slave.write_coils(0x13,[1,0,1,1, 0,0,1,1, 1,0]) }.should raise_response_mismatch(
        "Address is mismatch (expected 19, got 20)",
        request, response)
   end

   it "should raise error if quantity of coils is mismatch" do
      request = "\xf\x0\x13\x0\xa\2\xcd\x01"
      response = "\xf\x0\x13\x0\x9"
      mock_query!(request, response)

      lambda{ @slave.write_coils(0x13,[1,0,1,1, 0,0,1,1, 1,0]) }.should raise_response_mismatch(
        "Quantity is mismatch (expected 10, got 9)",
        request, response)
    end
  end

  describe "write multiple registers" do
    it "should raise error if address of first register is mismatch" do
      request = "\x10\x0\x1\x0\x2\x4\x0\xa\x1\x2"
      response = "\x10\x0\x2\x0\x2"
      mock_query!(request, response)

      lambda{ @slave.write_holding_registers(0x1,[0xa,0x102]) }.should raise_response_mismatch(
        "Address is mismatch (expected 1, got 2)",
        request, response)
   end

   it "should raise error if quantity of registers is mismatch" do
      request = "\x10\x0\x1\x0\x2\x4\x0\xa\x1\x2"
      response = "\x10\x0\x2\x0\x1"
      mock_query!(request, response)

      lambda{ @slave.write_holding_registers(0x1,[0xa,0x102]) }.should raise_response_mismatch(
        "Quantity is mismatch (expected 2, got 1)",
        request, response)
    end
  end


  private
  def mock_query!(request, response)
    @slave.should_receive(:send_pdu).with(request)
    @slave.should_receive(:read_pdu).and_return(response)
  end
end
