# -*- coding: ascii
# frozen_string_literal: true

require "rmodbus"

# Use public wrap method
module ModBus
  class Client
    include ModBus::RTU
    def test_read_method(msg)
      io = TestIO.new(msg)
      read_rtu_response(io)
    end
  end
end

class TestIO
  def initialize(msg)
    @msg = msg
  end

  def read(num)
    result = @msg[0, num]
    @msg = @msg[num..-1]
    result
  end
end

describe ModBus::Client do
  describe "#read_rtu_response" do
    before do
      @cl_mb = ModBus::Client.new
    end

    it "reads response for 'read coils'" do
      resp = make_resp("\x1\x3\xcd\x6b\x05")
      expect(@cl_mb.test_read_method(resp)).to eq(resp)
    end

    it "reads response for 'read discrete inputs'" do
      resp = make_resp("\x2\x3\xac\xdb\x35")
      expect(@cl_mb.test_read_method(resp)).to eq(resp)
    end

    it "reads response for 'read holding registers'" do
      resp = make_resp("\x3\x6\x2\x2b\x0\x0\x0\x64")
      expect(@cl_mb.test_read_method(resp)).to eq(resp)
    end

    it "reads response for 'read input registers'" do
      resp = make_resp("\x4\x2\x0\xa")
      expect(@cl_mb.test_read_method(resp)).to eq(resp)
    end

    it "reads response for 'write single coil'" do
      resp = make_resp("\x5\x0\xac\xff\x0")
      expect(@cl_mb.test_read_method(resp)).to eq(resp)
    end

    it "reads response for 'write single register'" do
      resp = make_resp("\x6\x0\x1\x0\x3")
      expect(@cl_mb.test_read_method(resp)).to eq(resp)
    end

    it "reads response for 'write multiple coils'" do
      resp = make_resp("\xf\x0\x13\x0\xa")
      expect(@cl_mb.test_read_method(resp)).to eq(resp)
    end

    it "reads response for 'write multiple registers'" do
      resp = make_resp("\x10\x0\x1\x0\x2")
      expect(@cl_mb.test_read_method(resp)).to eq(resp)
    end

    it "reads response 'mask write register'" do
      resp = make_resp("\x16\x0\x4\x0\xf2\x0\x25")
      expect(@cl_mb.test_read_method(resp)).to eq(resp)
    end

    it "reads exception codes" do
      resp = make_resp("\x84\x3")
      expect(@cl_mb.test_read_method(resp)).to eq(resp)
    end

    it "raises exception if function is illegal" do
      resp = make_resp("\x1f\x0\x1\x0\x2")
      expect { @cl_mb.test_read_method(resp) }.to raise_error(
        ModBus::Errors::IllegalFunction
      )
    end

    def make_resp(msg)
      "\x01#{msg}\x02\x02" # slave + msg + mock_crc
    end
  end
end
