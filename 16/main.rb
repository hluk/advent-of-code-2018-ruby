#!/usr/bin/env ruby
require 'set'

BEFORE_LABEL = 'Before: ['.freeze
AFTER_LABEL = 'After:  ['.freeze
OPS = %w[addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr].freeze

class Device
  def initialize
    @r = Array.new(4, 0)
  end

  def registers=(value)
    @r = value.dup
  end

  def registers
    @r
  end

  def op(name, a, b, c)
    case name
    when 'addr'
      @r[c] = @r[a] + @r[b]
    when 'addi'
      @r[c] = @r[a] + b

    when 'mulr'
      @r[c] = @r[a] * @r[b]
    when 'muli'
      @r[c] = @r[a] * b

    when 'banr'
      @r[c] = @r[a] & @r[b]
    when 'bani'
      @r[c] = @r[a] & b

    when 'borr'
      @r[c] = @r[a] | @r[b]
    when 'bori'
      @r[c] = @r[a] | b

    when 'setr'
      @r[c] = @r[a]
    when 'seti'
      @r[c] = a

    when 'gtir'
      @r[c] = a > @r[b] ? 1 : 0
    when 'gtri'
      @r[c] = @r[a] > b ? 1 : 0
    when 'gtrr'
      @r[c] = @r[a] > @r[b] ? 1 : 0

    when 'eqir'
      @r[c] = a == @r[b] ? 1 : 0
    when 'eqri'
      @r[c] = @r[a] == b ? 1 : 0
    when 'eqrr'
      @r[c] = @r[a] == @r[b] ? 1 : 0

    else
      raise "Unknown op name #{name}"
    end
  end
end

class Instruction
  attr_accessor :before
  attr_accessor :instruction
  attr_accessor :after

  def matches(op_name)
    device = Device.new
    device.registers = @before
    device.op(op_name, @instruction[1], @instruction[2], @instruction[3])
    device.registers == @after
  end
end

class Instructions
  attr_accessor :instructions
  attr_accessor :program_start

  def initialize(input)
    @instructions = []
    @program_start = 0

    instruction = nil

    input.each_with_index do |line, i|
      index = i % 4
      line.chomp!
      case index
      when 0
        unless line.start_with?(BEFORE_LABEL)
          @program_start = i + 2
          break
        end

        raise if instruction

        instruction = Instruction.new
        instruction.before = line[BEFORE_LABEL.length..-2].split(', ').map(&:to_i).freeze

      when 1
        instruction.instruction = line.split(' ').map(&:to_i).freeze

      when 2
        raise "Expected After label on line #{i + 1}" unless line.start_with?(AFTER_LABEL)

        instruction.after = line[AFTER_LABEL.length..-2].split(', ').map(&:to_i).freeze
        @instructions.push(instruction.freeze)
        instruction = nil

      else
        raise "Unexpected input on line #{i + 1}" unless line.empty?
      end
    end
  end
end

def find_op_mapping(op_codes, used_op_codes = Set.new, op_code = 0)
  return used_op_codes.to_a unless op_codes.include?(op_code)

  (op_codes[op_code] - used_op_codes).each do |possible_op_code|
    result = find_op_mapping(op_codes, used_op_codes + [possible_op_code], op_code + 1)
    return result if result
  end

  nil
end

input = ARGF.readlines

op_codes = Hash.new { |h, k| h[k] = Set.new }
insts = Instructions.new(input)
part1 = insts.instructions.count do |inst|
  OPS.count do |op_name|
    matches = inst.matches(op_name)
    op_codes[inst.instruction[0]].add(op_name) if matches
    matches
  end >= 3
end
puts part1

mapping = find_op_mapping(op_codes)
raise unless mapping
raise unless Set.new(mapping).length == 16
raise unless insts.instructions.all? do |inst|
  inst.matches(mapping[inst.instruction[0]])
end

device = Device.new
input[insts.program_start..-1].each do |line|
  instruction = line.split(' ').map(&:to_i)
  op_name = mapping[instruction[0]]
  device.op(op_name, instruction[1], instruction[2], instruction[3])
end
puts device.registers[0]
