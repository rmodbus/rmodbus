module ModBus
  # Module for implementation ModBus server
  module Server
    autoload :Slave, 'rmodbus/server/slave'

    Funcs = [1,2,3,4,5,6,15,16]

    def with_slave(uid)
      slave = slaves[uid] ||= Server::Slave.new
      if block_given?
        yield slave
      else
        slave
      end
    end

    private

    def slaves
      @slaves ||= {}
    end

    def exec_req(req, uid)
      if uid == 0
        slaves.each_key { |uid| exec_req(req, uid) }
        return
      end
      return nil unless (slave = slaves[uid])

      func = req.getbyte(0)

      unless Funcs.include?(func)
        params = { :err => 1 }
      end

      case func
        when 1
          params = parse_read_func(req, slave.coils, 2000)
          if params[:err] == 0
            val = slave.coils[params[:addr],params[:quant]].pack_to_word
            pdu = func.chr + val.size.chr + val
          end
        when 2
          params = parse_read_func(req, slave.discrete_inputs, 2000)
          if params[:err] == 0
            val = slave.discrete_inputs[params[:addr],params[:quant]].pack_to_word
            pdu = func.chr + val.size.chr + val
          end
        when 3
          params = parse_read_func(req, slave.holding_registers)
          if params[:err] == 0
            pdu = func.chr + (params[:quant] * 2).chr + slave.holding_registers[params[:addr],params[:quant]].pack('n*')
          end
        when 4
          params = parse_read_func(req, slave.input_registers)
          if params[:err] == 0
            pdu = func.chr + (params[:quant] * 2).chr + slave.input_registers[params[:addr],params[:quant]].pack('n*')
          end
        when 5
          params = parse_write_coil_func(req, slave)
          if params[:err] == 0
            slave.coils[params[:addr]] = params[:val]
            pdu = req
          end
        when 6
          params = parse_write_register_func(req, slave)
          if params[:err] == 0
            slave.holding_registers[params[:addr]] = params[:val]
            pdu = req
          end
        when 15
          params = parse_write_multiple_coils_func(req, slave)
          if params[:err] == 0
            slave.coils[params[:addr],params[:quant]] = params[:val][0,params[:quant]]
            pdu = req[0,5]
          end
        when 16
          params = parse_write_multiple_registers_func(req, slave)
          if params[:err] == 0
            slave.holding_registers[params[:addr],params[:quant]] = params[:val][0,params[:quant]]
            pdu = req[0,5]
          end
      end

      if params[:err] == 0
        pdu
      else
        (func | 0x80).chr + params[:err].chr
      end
    end

    def parse_read_func(req, field, quant_max=0x7d)
      quant = req[3,2].unpack('n')[0]

      return { :err => 3} unless quant <= quant_max

      addr = req[1,2].unpack('n')[0]
      return { :err => 2 } unless addr + quant <= field.size

      return { :err => 0, :quant => quant, :addr => addr }
    end

    def parse_write_coil_func(req, slave)
      addr = req[1,2].unpack('n')[0]
      return { :err => 2 } unless addr <= slave.coils.size

      val = req[3,2].unpack('n')[0]
      return { :err => 3 } unless val == 0 or val == 0xff00

      val = 1 if val == 0xff00
      return { :err => 0, :addr => addr, :val => val }
    end

    def parse_write_register_func(req, slave)
      addr = req[1,2].unpack('n')[0]
      return { :err => 2 } unless addr <= slave.holding_registers.size

      val = req[3,2].unpack('n')[0]

      return { :err => 0, :addr => addr, :val => val }
	  end

    def parse_write_multiple_coils_func(req, slave)
      params = parse_read_func(req, slave.coils)

      if params[:err] == 0
        params = {:err => 0, :addr => params[:addr], :quant => params[:quant], :val => req[6,params[:quant]].unpack_bits }
      end
      params
    end

    def parse_write_multiple_registers_func(req, slave)
      params = parse_read_func(req, slave.holding_registers)

      if params[:err] == 0
        params = {:err => 0, :addr => params[:addr], :quant => params[:quant], :val => req[6,params[:quant] * 2].unpack('n*')}
      end
      params
    end
  end
end
