$:.unshift File.join(File.dirname(__FILE__),'../lib')

require 'rmodbus'
require 'benchmark'

include ModBus

TIMES = 1000

srv = ModBus::RTUViaTCPServer.new 1502 
srv.coils = [0,1]  * 50
srv.discrete_inputs = [1,0]  * 50
srv.holding_registers = [0,1,2,3,4,5,6,7,8,9]  * 10
srv.input_registers = [0,1,2,3,4,5,6,7,8,9]  * 10
srv.start


cl = RTUClient.new('127.0.0.1', 1502)
cl.with_slave(1) do |slave|
  Benchmark.bmbm do |x|
    x.report('Read coils') do
      TIMES.times { slave.read_coils 0, 100 }
    end
    
    x.report('Read discrete inputs') do
      TIMES.times { slave.read_discrete_inputs 0, 100 }
    end
    
    x.report('Read holding registers') do
      TIMES.times { slave.read_holding_registers 0, 100 } 
    end
    
    x.report('Read input registers') do
      TIMES.times { slave.read_input_registers 0, 100 }
    end
    
    x.report('Write single coil') do
      TIMES.times { slave.write_single_coil 0, 1 }
    end
    
    x.report('Write single register') do
      TIMES.times { slave.write_single_register 100, 0xAAAA }
    end
    
    x.report('Write multiple coils') do
      TIMES.times { slave.write_multiple_coils 0, [1,0] * 50 }
    end    
    
    x.report('Write multiple registers') do
      TIMES.times { slave.write_multiple_registers 0, [0,1,2,3,4,5,6,7,8,9] * 10  }
    end
  end
end
cl.close
srv.stop
