#!/usr/bin/env ruby
require 'set'

frequency_diffs = File.readlines('input').map(&:to_i)
puts frequency_diffs.sum

frequencies = Set.new([0])
frequency = 0
loop do
  frequency_diffs.each do |freqency_diff|
    frequency += freqency_diff
    if frequencies.include?(frequency)
      puts frequency
      exit
    end
    frequencies.add(frequency)
  end
end
