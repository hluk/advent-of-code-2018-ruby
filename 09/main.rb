#!/usr/bin/env ruby

class CircleNode
  attr_accessor :value, :prev, :next

  def initialize(value)
    @value = value
    @prev = self
    @next = self
  end

  def remove
    @prev.next = @next
    @next.prev = @prev
    @value
  end

  def insert(value)
    node = CircleNode.new(value)
    node.prev = self
    node.next = @next
    @next.prev = node
    @next = node
    node
  end
end

def high_score(player_count, last_marble)
  players = Array.new(player_count, 0)
  circle = CircleNode.new(0)

  (23..last_marble).step(23) do |marble|
    (marble - 22...marble).each { |marble1| circle = circle.next.insert(marble1) }

    6.times { circle = circle.prev }
    removed_marble = circle.prev.remove

    current_player = (marble - 1) % player_count
    players[current_player] += marble + removed_marble
  end

  players.max
end

#require "minitest/test"
#
#class TestHighScore < MiniTest::Test
#  def test_examples
#    assert_equal high_score(10, 25), 32
#    assert_equal high_score(10, 1618), 8317
#    assert_equal high_score(13, 7999), 146373
#    assert_equal high_score(17, 1104), 2764
#    assert_equal high_score(21, 6111), 54718
#    assert_equal high_score(30, 5807), 37305
#  end
#end
#
#exit 1 unless Minitest.run

require 'rspec/core'
require 'rspec/expectations'

RSpec.describe '#high_score' do
  it 'returns high score' do
    expect(high_score(10, 25)).to eq(32)
    expect(high_score(10, 1618)).to eq(8317)
    expect(high_score(13, 7999)).to eq(146373)
    expect(high_score(17, 1104)).to eq(2764)
    expect(high_score(21, 6111)).to eq(54718)
    expect(high_score(30, 5807)).to eq(37305)
  end
end

exit 1 unless RSpec::Core::Runner.run([]).zero?

puts high_score(435, 71184)
puts high_score(435, 7118400)
