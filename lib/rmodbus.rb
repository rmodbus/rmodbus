# frozen_string_literal: true

require "rmodbus/ext"
require "rmodbus/proxy"
require "rmodbus/version"

module ModBus
  autoload :Errors, "rmodbus/errors"
  autoload :Debug, "rmodbus/debug"
  autoload :Options, "rmodbus/options"
  autoload :SP, "rmodbus/sp"
  autoload :RTU, "rmodbus/rtu"
  autoload :TCP, "rmodbus/tcp"
  autoload :Client, "rmodbus/client"
  autoload :Server, "rmodbus/server"
  autoload :TCPSlave, "rmodbus/tcp_slave"
  autoload :TCPClient, "rmodbus/tcp_client"
  autoload :TCPServer, "rmodbus/tcp_server"
  autoload :RTUSlave, "rmodbus/rtu_slave"
  autoload :RTUClient, "rmodbus/rtu_client"
  autoload :RTUServer, "rmodbus/rtu_server"
  autoload :RTUViaTCPServer, "rmodbus/rtu_via_tcp_server"
end
