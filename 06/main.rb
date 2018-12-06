#!/usr/bin/env ruby
MAX_DISTANCE = 10000
INDEX = (('a'..'z').to_a + ('A'..'Z').to_a).freeze

def shortest_distance_to(x, y, coords)
  distances = coords.map { |x1, y1| (x1 - x).abs + (y1 - y).abs }
  min1, min2 = distances.each_with_index.min_by(2) { |d, _| d }
  return '.' if min1[0] == min2[0]

  INDEX[min1[1]]
end

coords = ARGF.readlines.map { |line| line.split(', ').map(&:to_i) }

# find bounding box
min_x, max_x = coords.map { |x, _| x }.minmax
min_y, max_y = coords.map { |_, y| y }.minmax
map_x = max_x - min_x + 1
map_y = max_y - min_y + 1

# crop area
coords.map! { |x, y| [x - min_x, y - min_y] }

map = Array.new(map_y) { Array.new(map_x) }

(0...map_y).each do |y|
  (0...map_x).each do |x|
    map[y][x] = shortest_distance_to(x, y, coords)
  end
end

# puts(map.map { |row| row.join('') }.join("\n"))

counters = Hash.new(0)
map.each do |row|
  row.each do |index|
    counters[index] += 1
  end
end

# drop infinite areas
map.first.each { |index| counters.delete(index) }
map.last.each { |index| counters.delete(index) }
map.each do |row|
  counters.delete(row.first)
  counters.delete(row.last)
end

puts(counters.max_by { |_, v| v })

area = 0
(0...map_y).each do |y|
  (0...map_x).each do |x|
    distance_sum = coords.sum { |xx, yy| (xx - x).abs + (yy - y).abs }
    area += 1 if distance_sum < MAX_DISTANCE
  end
end

puts area
