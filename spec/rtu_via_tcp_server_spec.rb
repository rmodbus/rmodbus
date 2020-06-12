# -*- coding: ascii
require "rmodbus"

describe ModBus::RTUViaTCPServer do
  it "should have options :host" do
    host = '192.168.0.1'
    srv = ModBus::RTUViaTCPServer.new(1010, :host => '192.168.0.1')
    srv.host.should eql(host)
  end

  it "should have options :max_connection" do
    max_conn = 5
    srv = ModBus::RTUViaTCPServer.new(1010, :max_connection => 5)
    srv.maxConnections.should eql(max_conn)
  end
end
