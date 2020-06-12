module ModBus
  # Module for implementation ModBus server
  module Server
    autoload :Slave, 'rmodbus/server/slave'

    attr_accessor :promiscuous

    Funcs = [1,2,3,4,5,6,15,16,22,23]

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
      slave = slaves[uid]
      return nil if !slave && !promiscuous

      func = req.getbyte(0)

      if promiscuous && !slave && @pending_response_uid == uid
        # we saw a request to a slave that we don't own; try
        # and parse this as a response, not a request

        if func & 0x80 == 0x80
          func &= 0x7f
          params = { err: req.getbyte(1) }
        else
          params = parse_response(func, req, @pending_response_req)
        end
        log("Server RX response #{func} from #{uid}: #{params.inspect}")
        return
      end

      unless Funcs.include?(func)
        log("Server RX unrecognized function #{func} to #{uid}")
        return unless slave
        return (func | 0x80).chr + 1.chr
      end

      @pending_response_uid = uid
      # keep track of the request so that promiscuous printing of the response can have context if necessary
      @pending_response_req = req
      params = parse_request(func, req)
      unless params
        log("Server RX unable to parse function #{func} to #{uid}")
        return unless slave
        return (func | 0x80).chr + 1.chr
      end
      log("Server RX function #{func} to #{uid}: #{params.inspect}")

      return unless slave
      process_func(func, slave, req, params)
    end

    def parse_request(func, req)
      case func
      when 1, 2, 3, 4
        parse_read_func(req)
      when 5
        parse_write_coil_func(req)
      when 6
        parse_write_register_func(req)
      when 15
        parse_write_multiple_coils_func(req)
      when 16
        parse_write_multiple_registers_func(req)
      when 22
        parse_mask_write_register_func(req)
      when 23
        parse_read_write_multiple_registers_func(req)
      end
    end

    def parse_response(func, res, req)
      case func
      when 1, 2
        res[2..-1].unpack_bits[0..parse_read_func(req)[:quant]]
      when 3, 4
        res[2..-1].unpack('n*')
      when 5, 6, 15, 16
        {}
      end
    end

    def process_func(func, slave, req, params)
      case func
        when 1
          unless (err = validate_read_func(params, slave.coils, 2000))
            val = slave.coils[params[:addr],params[:quant]].pack_to_word
            pdu = func.chr + val.size.chr + val
          end
        when 2
          unless (err = validate_read_func(params, slave.discrete_inputs, 2000))
            val = slave.discrete_inputs[params[:addr],params[:quant]].pack_to_word
            pdu = func.chr + val.size.chr + val
          end
        when 3
          unless (err = validate_read_func(params, slave.holding_registers))
            pdu = func.chr + (params[:quant] * 2).chr + slave.holding_registers[params[:addr],params[:quant]].pack('n*')
          end
        when 4
          unless (err = validate_read_func(params, slave.input_registers))
            pdu = func.chr + (params[:quant] * 2).chr + slave.input_registers[params[:addr],params[:quant]].pack('n*')
          end
        when 5
          unless (err = validate_write_coil_func(params, slave))
            params[:val] = 1 if params[:val] == 0xff00
            slave.coils[params[:addr]] = params[:val]
            pdu = req
          end
        when 6
          unless (err = validate_write_register_func(params, slave))
            slave.holding_registers[params[:addr]] = params[:val]
            pdu = req
          end
        when 15
          unless (err = validate_write_multiple_coils_func(params, slave))
            slave.coils[params[:addr],params[:quant]] = params[:val][0,params[:quant]]
            pdu = req[0,5]
          end
        when 16
          unless (err = validate_write_multiple_registers_func(params, slave))
            slave.holding_registers[params[:addr],params[:quant]] = params[:val]
            pdu = req[0,5]
          end
        when 22
          unless (err = validate_write_register_func(params, slave))
            addr = params[:addr]
            and_mask = params[:and_mask]
            slave.holding_registers[addr] = (slave.holding_registers[addr] & and_mask) | (params[:or_mask] & ~and_mask)
            pdu = req
          end
        when 23
          unless (err = validate_read_write_multiple_registers_func(params, slave))
            slave.holding_registers[params[:write][:addr],params[:write][:quant]] = params[:write][:val]
            pdu = func.chr + (params[:read][:quant] * 2).chr + slave.holding_registers[params[:read][:addr],params[:read][:quant]].pack('n*')
          end
      end

      if err
        (func | 0x80).chr + err.chr
      else
        pdu
      end
    end

    def parse_read_func(req, expected_length = 5)
      return nil if expected_length && req.length != expected_length
      { quant: req[3,2].unpack('n')[0], addr: req[1,2].unpack('n')[0] }
    end

    def validate_read_func(params, field, quant_max=0x7d)
      return 3 unless params[:quant] <= quant_max
      return 2 unless params[:addr] + params[:quant] <= field.size
    end

    def parse_write_coil_func(req)
      return nil unless req.length == 5
      { addr: req[1,2].unpack('n')[0], val: req[3,2].unpack('n')[0] }
    end

    def validate_write_coil_func(params, slave)
      return 2 unless params[:addr] <= slave.coils.size
      return 3 unless params[:val] == 0 or params[:val] == 0xff00
    end

    def parse_write_register_func(req)
      return nil unless req.length == 5
      { addr: req[1,2].unpack('n')[0], val: req[3,2].unpack('n')[0] }
    end

    def validate_write_register_func(params, slave)
      return 2 unless params[:addr] <= slave.holding_registers.size
    end

    def parse_write_multiple_coils_func(req)
      return nil if req.length < 7
      params = parse_read_func(req, nil)
      return nil if req.length != 6 + (params[:quant] + 7) / 8
      params[:val] = req[6,params[:quant]].unpack_bits
      params
    end

    def validate_write_multiple_coils_func(params, slave)
      validate_read_func(params, slave.coils)
    end

    def parse_write_multiple_registers_func(req)
      return nil if req.length < 8
      params = parse_read_func(req, nil)
      return nil if req.length != 6 + params[:quant] * 2
      params[:val] = req[6,params[:quant] * 2].unpack('n*')
      params
    end

    def validate_write_multiple_registers_func(params, slave)
      validate_read_func(params, slave.holding_registers)
    end

    def parse_mask_write_register_func(req)
      return nil if req.length != 7
      {
          addr: req[1,2].unpack('n')[0],
          and_mask: req[3,2].unpack('n')[0],
          or_mask: req[5,2].unpack('n')[0]
      }
    end

    def parse_read_write_multiple_registers_func(req)
      return nil if req.length < 12
      params = { read: parse_read_func(req, nil),
        write: parse_write_multiple_registers_func(req[4..-1])}
      return nil if params[:write].nil?
      params
    end

    def validate_read_write_multiple_registers_func(params, slave)
      result = validate_read_func(params[:read], slave.holding_registers)
      return result if result
      validate_write_multiple_registers_func(params[:write], slave)
    end
  end
end
