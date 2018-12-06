#!/usr/bin/env ruby
MAX_DISTANCE = 10000

def shortest_distance_to(x, y, coords)
  distances = coords.map { |x1, y1| (x1 - x).abs + (y1 - y).abs }
  min1, min2 = distances.each_with_index.min_by(2) { |d, _| d }
  return -1 if min1[0] == min2[0]

  min1[1]
end

coords = ARGF.readlines.map { |line| line.split(', ').map(&:to_i) }

# find bounding box
min_x, max_x = coords.map { |x, _| x }.minmax
min_y, max_y = coords.map { |_, y| y }.minmax
map_x = max_x - min_x + 1
map_y = max_y - min_y + 1

# crop area
coords.map! { |x, y| [x - min_x, y - min_y] }

counters = Array.new(coords.length, 0)
(0...map_y).each do |y|
  (0...map_x).each do |x|
    index = shortest_distance_to(x, y, coords)
    if x.between?(1, map_x - 2) && y.between?(1, map_y - 2) && counters[index] != -1
      counters[index] += 1
    else
      counters[index] = -1
    end
  end
end

puts counters.max

area = 0
(0...map_y).each do |y|
  (0...map_x).each do |x|
    distance_sum = coords.sum { |xx, yy| (xx - x).abs + (yy - y).abs }
    area += 1 if distance_sum < MAX_DISTANCE
  end
end

puts area
