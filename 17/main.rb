#!/usr/bin/env ruby

class WaterMap
  def initialize(input)
    @map = {}
    @x_min = 99999
    @y_min = 99999
    @x_max = 0
    @y_max = 0

    input.each do |line|
      c1, c2 = line.split(', ')
      c2, c2_end = c2.split('..')
      c1, c1_start = c1.split('=')
      c2, c2_start = c2.split('=')
      c1_start = c1_start.to_i
      c2_start = c2_start.to_i
      c2_end = c2_end.to_i
      if c1 == 'x'
        raise unless c2 == 'y'

        @x_min = [@x_min, c1_start].min
        @y_min = [@y_min, c2_start].min
        @x_max = [@x_max, c1_start].max
        @y_max = [@y_max, c2_end].max
        (c2_start..c2_end).each { |c| @map[[c, c1_start]] = '#' }
      else
        raise unless c2 == 'x'

        @x_min = [@x_min, c2_start].min
        @y_min = [@y_min, c1_start].min
        @x_max = [@x_max, c2_end].max
        @y_max = [@y_max, c1_start].max
        (c2_start..c2_end).each { |c| @map[[c1_start, c]] = '#' }
      end
    end

    @x_min -= 1
    @x_max += 1
  end

  def pour(y, x)
    return if get(y, x) == '|' # already poured?

    bottom = y.upto(@y_max + 1).find { |yy| get(yy, x) != '.' } || @y_max + 1
    (y..bottom - 1).each { |yy| set(yy, x, '|') }

    return if get(bottom, x) == '|' # already poured?

    set(y, x, '+') if y.zero?
    y = bottom - 1

    spread(y, x) if y < @y_max
  end

  def spread(y, x)
    left = (x - 1).downto(@x_min).find { |xx| !holds_water?(y, xx) }
    right = (x + 1).upto(@x_max).find { |xx| !holds_water?(y, xx) }
    pour_left = get(y, left) != '#'
    pour_right = get(y, right) != '#'
    char = pour_left || pour_right ? '|' : '~'
    (left + 1..right - 1).each { |xx| set(y, xx, char) }

    pour(y, left) if pour_left
    pour(y, right) if pour_right
    spread(y - 1, x) if y != @y_min && !pour_left && !pour_right
  end

  def get(y, x)
    @map.fetch([y, x], '.')
  end

  def set(y, x, char)
    @last_set = [y, x]
    raise if get(y, x) == '#'

    @map[@last_set] = char
  end

  def holds_water?(y, x)
    get(y, x) != '#' && '#~'.include?(get(y + 1, x))
  end

  def water_count(water)
    @map.count { |pos, char| pos[0] >= @y_min && water.include?(char) }
  end

  def to_s
    (0..@y_max).map do |y|
      (@x_min..@x_max).map do |x|
        get(y, x)
      end.join + "\n"
    end.join + "\n"
  end
end

input = ARGF.readlines
map = WaterMap.new(input)
map.pour(0, 500)
puts map
puts map.water_count('|~')
puts map.water_count('~')
