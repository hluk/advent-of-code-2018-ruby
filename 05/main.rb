#!/usr/bin/env ruby
def reduce_polymer(polymer)
  (polymer.length - 2).downto(0) do |i|
    polymer[i..i + 1] = '' if polymer[i] == polymer[i + 1].swapcase
  end

  polymer.length
end

def min_length(polymer)
  ('a'..'z')
    .map { |letter| polymer.tr("#{letter}#{letter.upcase}", '') }
    .map(&method(:reduce_polymer))
    .min
end

polymer = ARGF.read.chomp

puts reduce_polymer(polymer)
puts min_length(polymer)
