#!/usr/bin/env ruby
require 'set'
require 'rspec/core'
require 'rspec/expectations'

def distance(coord1, coord2)
  coord1.each.with_index.sum { |x, i| (x - coord2[i]).abs }
end

def part1(input)
  coords = input.map { |line| line.strip.split(',').map(&:to_i) }
  constellations = Set.new
  coords.each do |coord|
    matching = constellations.find_all do |constellation|
      constellation.any? { |coord2| distance(coord, coord2) <= 3 }
    end

    new = matching.sum([coord])
    constellations.subtract(matching)
    constellations.add(new)
  end

  constellations.length
end

describe 'part1' do
  it 'returns constellation count' do
    expect(part1(File.readlines('input_test'))).to eq(2)
    expect(part1(File.readlines('input_test1'))).to eq(1)
    expect(part1(File.readlines('input_test2'))).to eq(4)
    expect(part1(File.readlines('input_test3'))).to eq(3)
    expect(part1(File.readlines('input_test4'))).to eq(8)
  end
end

exit 1 unless RSpec::Core::Runner.run([]).zero?

input = ARGF.readlines
puts part1(input)
