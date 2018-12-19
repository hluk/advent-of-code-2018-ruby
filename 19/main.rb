#!/usr/bin/env ruby

class Device
  attr_accessor :ip

  def initialize
    @r = Array.new(6, 0)
    @ip = 0
  end

  def registers=(value)
    @r = value.dup
  end

  def registers
    @r
  end

  def addr(a, b); @r[a] + @r[b] end
  def addi(a, b); @r[a] + b end

  def mulr(a, b); @r[a] * @r[b] end
  def muli(a, b); @r[a] * b end

  def banr(a, b); @r[a] & @r[b] end
  def bani(a, b); @r[a] & b end

  def borr(a, b); @r[a] | @r[b] end
  def bori(a, b); @r[a] | b end

  def setr(a, b); @r[a] end
  def seti(a, b); a end

  def gtir(a, b); a > @r[b] ? 1 : 0 end
  def gtri(a, b); @r[a] > b ? 1 : 0 end
  def gtrr(a, b); @r[a] > @r[b] ? 1 : 0 end

  def eqir(a, b); a == @r[b] ? 1 : 0 end
  def eqri(a, b); @r[a] == b ? 1 : 0 end
  def eqrr(a, b); @r[a] == @r[b] ? 1 : 0 end

  def run(program)
    prog = program.map { |inst, a, b, c| [method(inst), a, b, c] }
    r = @r

    loop do
      ip = r[@ip]
      inst, a, b, c = prog[ip]
      break unless inst

      # cheating here: manually optimized loop
      if ip == 3
        r[0] += r[3] if (r[5] % r[3]).zero?
        r[2] = r[5] + 1
        r[1] = 1
        r[4] = 12
      else
        r[c] = inst.call(a, b)
        r[@ip] += 1
      end
    end
  end
end

input = ARGF.readlines
ip_pragma = input[0].split(' ')
raise unless ip_pragma[0] == '#ip'

device = Device.new
device.ip = ip_pragma[1].to_i

program = input[1..-1].map do |line|
  line.split(' ').map { |x| x[0].between?('0', '9') ? x.to_i : x }
end

device.run(program)
puts device.registers[0]

device = Device.new
device.ip = ip_pragma[1].to_i
device.registers[0] = 1
device.run(program)
puts device.registers[0]
