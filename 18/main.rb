#!/usr/bin/env ruby
def count_adjacent(map, y, x)
  count = Hash.new(0)
  [
    [y - 1, x - 1],
    [y - 1, x + 0],
    [y - 1, x + 1],

    [y + 0, x - 1],
    [y + 0, x + 1],

    [y + 1, x - 1],
    [y + 1, x + 0],
    [y + 1, x + 1]
  ].each do |yy, xx|
    next if yy < 0 || xx < 0

    count[map.fetch(yy, [])[xx]] += 1
  end
  count
end

def tick(map)
  map.map.with_index do |row, y|
    row.map.with_index do |acre, x|
      count = count_adjacent(map, y, x)
      if acre == '.' && count['|'] >= 3
        '|'
      elsif acre == '|' && count['#'] >= 3
        '#'
      elsif acre == '#' && !(count['#'] >= 1 && count['|'] >= 1)
        '.'
      else
        acre
      end
    end
  end
end

def render(map)
  map.map(&:join).join("\n") + "\n\n"
end

map = ARGF.readlines.each.map do |line|
  line.chomp.chars
end
puts render(map)

cache = {}

times = 1000000000
times.times do |i|
  map2, cached_i = cache[map]
  if map2
    map = map2
    jump = (i - cached_i)
    rest = (times - i - 1) % jump
    rest.times { map, = cache[map] }
    break
  end

  map2 = tick(map)
  cache[map] = [map2, i]
  map = map2

  puts i + 1 if (i % 10000) == 1
  #puts render(map)
end

trees = map.sum { |row| row.count { |acre| acre == '|' } }
lumberyards = map.sum { |row| row.count { |acre| acre == '#' } }
puts "trees: #{trees}"
puts "lumberyards: #{lumberyards}"
result = trees * lumberyards
puts "#{result}"
