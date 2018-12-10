#!/usr/bin/env ruby

input = ARGF.readlines.map do |line|
  /position=<(?<x>.+),\s*(?<y>.+)> velocity=<(?<dx>.+),\s*(?<dy>.+)>/ =~ line
  [x.to_i, y.to_i, dx.to_i, dy.to_i]
end

max_width = 1e10
max_height = 1e10
seconds = 0

loop do
  seconds += 1

  input.map! { |x, y, dx, dy| [x + dx, y + dy, dx, dy] }

  min_x, max_x = input.minmax_by { |x, _, _, _| x }.map { |x, _, _, _| x }
  min_y, max_y = input.minmax_by { |_, y, _, _| y }.map { |_, y, _, _| y }
  width = max_x - min_x + 1
  height = max_y - min_y + 1

  if height < 20
    puts "--- seconds: #{seconds}"
    map = Array.new(height) { '.' * width }

    input.each { |x, y, _, _| map[y - min_y][x - min_x] = '#' }

    puts map.join("\n")
  end

  break if width > max_width || height > max_height

  max_width = width
  max_height = height
end
