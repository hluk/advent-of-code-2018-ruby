#!/usr/bin/env ruby
require 'set'
require 'rspec/core'
require 'rspec/expectations'

NEITHER = 0
TORCH = 1
GEAR = 2

MOVE_TIME = 1
SWITCH_TIME = 7

class Cave
  def initialize(depth, target)
    @depth = depth
    @target = target
    @cave_max_x = @target[0] + 1000
    @erosion_cache = {}
  end

  def coord_hash(x, y)
    y * @cave_max_x + x
  end

  def geoindex(x, y)
    if (y.zero? && x.zero?) || (@target[0] == x && @target[1] == y)
      0
    elsif y.zero?
      x * 16807
    elsif x.zero?
      y * 48271
    else
      erosion(x - 1, y) * erosion(x, y - 1)
    end
  end

  def erosion(x, y)
    @erosion_cache[coord_hash(x, y)] ||= (geoindex(x, y) + @depth) % 20183
  end

  def type(x, y)
    erosion(x, y) % 3
  end

  def part1
    (0..@target[1]).sum do |y|
      (0..@target[0]).sum do |x|
        type(x, y)
      end
    end
  end

  def part2
    stacks = Hash.new { |h, k| h[k] = [] }
    stacks[0] = [[@target[0], @target[1], TORCH]]
    visited = Array.new(3) { Set.new }

    loop do
      time = stacks.keys.min
      stack = stacks[time]
      x, y, equipped = stack.shift
      unless x
        p time if (time % 50).zero?
        stacks.delete(time)
        raise if stacks.empty?

        next
      end

      next unless visited[equipped].add?(coord_hash(x, y))

      invalid_equipment = type(x, y)
      next if invalid_equipment == equipped

      return time if x.zero? && y.zero?

      moves = [[x, y + 1], [x + 1, y], [x, y - 1], [x - 1, y]].select do |x2, y2|
        x2 >= 0 && y2 >= 0
      end

      equip = [TORCH, GEAR, NEITHER] - [invalid_equipment, equipped]

      stacks[time + MOVE_TIME] += moves.map { |x2, y2| [x2, y2, equipped] }
      stacks[time + SWITCH_TIME] += equip.map { |equipment| [x, y, equipment] }
    end
  end
end

describe Cave do
  before(:example) do
    @cave = Cave.new(510, [10, 10])
  end

  it 'geoindex' do
    expect(@cave.geoindex(0, 0)).to eq(0)
    expect(@cave.geoindex(1, 0)).to eq(16807)
    expect(@cave.geoindex(0, 1)).to eq(48271)
    expect(@cave.geoindex(1, 1)).to eq(145722555)
    expect(@cave.geoindex(10, 10)).to eq(0)
  end

  it 'erosion' do
    expect(@cave.erosion(0, 0)).to eq(510)
    expect(@cave.erosion(1, 0)).to eq(17317)
    expect(@cave.erosion(0, 1)).to eq(8415)
    expect(@cave.erosion(1, 1)).to eq(1805)
    expect(@cave.erosion(10, 10)).to eq(510)
  end

  it 'type' do
    expect(@cave.type(0, 0)).to eq(0)
    expect(@cave.type(1, 0)).to eq(1)
    expect(@cave.type(0, 1)).to eq(0)
    expect(@cave.type(1, 1)).to eq(2)
    expect(@cave.type(10, 10)).to eq(0)
  end

  it 'part' do
    expect(@cave.part1).to eq(114)
    expect(@cave.part2).to eq(45)
  end
end

exit 1 unless RSpec::Core::Runner.run([]).zero?

cave = Cave.new(10914, [9, 739])
puts cave.part1
puts cave.part2
