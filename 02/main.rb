#!/usr/bin/env ruby
require 'set'

boxes = File.readlines('input')

letter_count_2_same = 0
letter_count_3_same = 0
boxes.each do |line|
  letter_counts = Hash.new(0)
  line.split('').each do |chr|
    letter_counts[chr] += 1
  end
  letter_count_2_same += 1 if letter_counts.any? { |_, v| v == 2 }
  letter_count_3_same += 1 if letter_counts.any? { |_, v| v == 3 }
end
puts "#{letter_count_2_same} * #{letter_count_3_same} = #{letter_count_2_same * letter_count_3_same}"

boxes.reverse!
boxes.each_with_index do |line1, i|
  boxes.lazy.drop(i + 1).each do |line2|
    diff = line1.each_char.with_index.to_set - line2.each_char.with_index
    if diff.count == 1
      puts line1, line2, diff
      exit
    end
  end
end
