#!/usr/bin/env ruby
GRID_ID = 7989
SIZE = 300

class PowerGrid
  def initialize(grid_id)
    @grid_id = grid_id
    @summed = Array.new(SIZE + 1) { Array.new(SIZE + 1, 0) }

    (1..SIZE).each do |y|
      (1..SIZE).each do |x|
        rack_id = x + 10
        @summed[y][x] = ((rack_id * y + @grid_id) * rack_id) % 1000 / 100 - 5 \
          + @summed[y - 1][x] \
          + @summed[y][x - 1] \
          - @summed[y - 1][x - 1]
      end
    end
  end

  def square(x, y, square_size)
    bottom = y + square_size - 1
    right = x + square_size - 1
    @summed[bottom][right] \
      - @summed[y - 1][right] \
      - @summed[bottom][x - 1] \
      + @summed[y - 1][x - 1]
  end

  def max_value(square_size)
    max_power = [0, 0, 0]
    (1..SIZE - square_size + 1).each do |y|
      (1..SIZE - square_size + 1).each do |x|
        power = square(x, y, square_size)
        max_power = [power, x, y] if power > max_power[0]
      end
    end
    max_power
  end

  def max_square
    max_power_square = [0, 0, 0, 0]
    (1..SIZE).each do |square_size|
      max_power = max_value(square_size)
      break if max_power[0] < max_power_square[0]

      max_power_square = max_power + [square_size]
    end
    max_power_square
  end
end

def power_level(x, y, grid_id)
  PowerGrid.new(grid_id).square(x, y, 1)
end

def max_power_level(grid_id, square_size)
  PowerGrid.new(grid_id).max_value(square_size)
end

def max_power_level_square(grid_id)
  PowerGrid.new(grid_id).max_square
end

require 'rspec/core'
require 'rspec/expectations'

RSpec.describe '#power_level' do
  it 'returns power level' do
    expect(power_level(3, 5, 8)).to eq(4)
    expect(power_level(122, 79, 57)).to eq(-5)
    expect(power_level(217, 196, 39)).to eq(0)
    expect(power_level(101, 153, 71)).to eq(4)
  end
end

RSpec.describe '#max_power_level' do
  it 'returns max power level' do
    expect(max_power_level(18, 3)).to eq([29, 33, 45])
    expect(max_power_level(42, 3)).to eq([30, 21, 61])
  end
end

RSpec.describe '#max_power_level_square' do
  it 'returns max power level square' do
    expect(max_power_level_square(18)).to eq([113, 90, 269, 16])
    expect(max_power_level_square(42)).to eq([119, 232, 251, 12])
  end
end

exit 1 unless RSpec::Core::Runner.run([]).zero?

max_power = max_power_level(GRID_ID, 3)
puts "power: #{max_power[0]} x,y: #{max_power[1]},#{max_power[2]}"

max_power_square = max_power_level_square(GRID_ID)
puts "power: #{max_power_square[0]} x,y,square: #{max_power_square[1]},#{max_power_square[2]},#{max_power_square[3]}"
