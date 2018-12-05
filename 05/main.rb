#!/usr/bin/env ruby
require 'set'

def trace_polymer(polymer, i, emph)
  return
  from = [i - 10, 0].max
  if emph
    print "#{polymer[from...i - 1]}_#{polymer[i - 1..i]}_#{polymer[i + 1..i + 10]}\n"
  else
    puts polymer[from..i + 10]
  end
end

def reduce_step(polymer, i)
  trace_polymer polymer, i, true
  polymer[i - 1..i] = ''
  trace_polymer polymer, i, false
  i -= 1
  if i < 0
    i = 1
  end
  i
end

def reduce_polymer(polymer)
  i = 1
  while i < polymer.length
    if polymer[i - 1].swapcase == polymer[i]
      i = reduce_step(polymer, i)
    else
      i += 1
    end
  end

  polymer.length
end

input_file = ARGV.fetch(0)
polymer = File.read(input_file).strip

puts reduce_polymer(polymer)

letters = Set.new(polymer.downcase.chars)
lengths = letters.map do |letter|
  polymer1 = polymer.clone
  polymer1.gsub!(letter.downcase, '')
  polymer1.gsub!(letter.upcase, '')
  reduce_polymer(polymer1)
  polymer1.length
end
puts lengths.min
