#!/usr/bin/env ruby
require 'set'

class Device
  attr_accessor :ip
  attr_accessor :r0_first
  attr_accessor :r0_last

  def initialize
    @r = Array.new(6, 0)
    @ip = 0
    @record_r0 = Set.new
    @record = Set.new
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

      if ip == 28
        r[0] = r[1] + 1
        break unless @record.add?(r[1..-1])

        @r0_first ||= r[1]
        @r0_last = r[1] if @record_r0.add?(r[1])
      end

      if ip == 17
        r[3] = r[4] / 256
      else
        r[c] = inst.call(a, b)
      end
      r[@ip] += 1
    end
  end
end

input = ARGF.readlines
ip_pragma = input[0].split(' ')
raise unless ip_pragma[0] == '#ip'

ip = ip_pragma[1].to_i

program = input[1..-1].map do |line|
  line.split(' ').map { |x| x[0].between?('0', '9') ? x.to_i : x }
end

device = Device.new
device.ip = ip
device.run(program)
puts device.r0_first
puts device.r0_last
