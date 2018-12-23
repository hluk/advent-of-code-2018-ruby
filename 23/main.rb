#!/usr/bin/env ruby
require 'set'
require 'rspec/core'
require 'rspec/expectations'

class Nanobot
  include Comparable

  attr_accessor :pos
  attr_accessor :r

  def initialize(pos, r)
    @pos = pos
    @r = r
  end

  def self.from_input(line)
    raise "Cannot parse line: #{line}" unless /pos=<(?<pos>.*)>, r=(?<r>\d+)/ =~ line

    pos = pos.split(',').map(&:to_i)
    Nanobot.new(pos, r.to_i)
  end

  def hash
    [@pos, @r].hash
  end

  def inspect
    "#<Nanobot #{@r} #{@pos.join(',')}>"
  end

  def to_s
    inspect
  end
end

class Intersection
  attr_accessor :bots

  include Comparable

  def initialize(bot)
    @bots = Set.new([bot])
  end

  def add(bot)
    @bots.add(bot) if @bots.all? { |bot1| bot != bot1 && Nanobots.intersects?(bot, bot1) }
  end

  def hash
    @bots.hash
  end

  def inspect
    "#<Intersection #{@bots.map(&:inspect).join(', ')}>"
  end

  def eql?(other)
    @bots.eql?(other.bots)
  end
end

class Nanobots
  attr_accessor :nanobots

  def initialize(nanobots)
    @nanobots = nanobots
  end

  def self.from_input(input)
    nanobots = input.map { |line| Nanobot.from_input(line) }
    Nanobots.new(nanobots)
  end

  def self.distance(pos1, pos2)
    pos1.each.with_index.sum { |d, i| (d - pos2[i]).abs }
  end

  def self.in_range?(pos, bot)
    Nanobots.distance(pos, bot.pos) <= bot.r
  end

  def self.intersects?(bot1, bot2)
    distance = Nanobots.distance(bot1.pos, bot2.pos)
    distance <= bot1.r + bot2.r
  end

  def strongest
    @nanobots.max_by(&:r)
  end

  def in_range(nanobot)
    @nanobots.select { |bot| Nanobots.in_range?(bot.pos, nanobot) }
  end

  def best_position
    intersects = Set.new(@nanobots)
    bot = intersects.max_by { |bot1| intersects.count { |bot2| Nanobots.intersects?(bot1, bot2) } }

    extents = [[-1, 0, 0], [0, -1, 0], [0, 0, -1], [1, 0, 0], [0, 1, 0], [0, 0, 1]]

    # Binary search for area with most intersects.
    until bot.r == 1
      # FIXME: What's the correct way of dividing the area?
      r = bot.r * 8 / 9
      shift = bot.r - r
      bot_intersects = extents.map do |d|
        pos = bot.pos.map.with_index { |x, i| x + d[i] * shift }
        bot1 = Nanobot.new(pos, r)
        intersects2 = intersects.select { |bot2| Nanobots.intersects?(bot1, bot2) }
        [bot1, intersects2]
      end
      bot, intersects = bot_intersects.max_by { |_, intersects2| intersects2.length }
    end

    count_pos = extents.map do |d|
      pos = bot.pos.map.with_index { |x, i| x + d[i] }
      count = intersects.count { |bot1| Nanobots.in_range?(pos, bot1) }
      [count, pos]
    end
    count_pos.max[1]
  end
end

describe 'Return nanobots in range of the strongest one' do
  before(:example) do
    input = File.readlines('input_test')
    @nanobots = Nanobots.from_input(input)
  end

  it 'returns strongest bot' do
    expect(@nanobots.strongest.r).to eq(4)
  end

  it 'returns bots in range' do
    bot = Nanobot.new([0, 0, 0], 4)
    in_range = @nanobots.in_range(bot)
    expect(in_range.length).to eq(7)
  end
end

describe 'Return position in range of the most bots' do
  before(:example) do
    input = File.readlines('input_test2')
    @nanobots = Nanobots.from_input(input)
  end

  it 'return position in range of the most bots' do
    expect(@nanobots.best_position).to eq([12, 12, 12])
    expect(Nanobots.distance([0, 0, 0], [12, 12, 12])).to eq(36)
  end
end

exit 1 unless RSpec::Core::Runner.run([]).zero?

input = ARGF.readlines.freeze
nanobots = Nanobots.from_input(input)

strongest = nanobots.strongest
part1 = nanobots.in_range(strongest)
puts part1.length

best_position = nanobots.best_position
part2 = Nanobots.distance([0, 0, 0], best_position)
puts part2
raise 'Answer is too high' if part2 >= 134383640
