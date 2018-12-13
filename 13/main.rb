#!/usr/bin/env ruby
class Cart
  attr_accessor :direction

  def initialize(direction)
    @direction = direction
    @turn_counter = 0
  end

  def turn!
    value = @turn_counter
    @turn_counter = (@turn_counter + 1) % 3
    value
  end
end

class Track
  attr_accessor :map
  attr_accessor :carts

  def initialize(input)
    rows = input.length
    columns = input[0].chomp.length
    @map = Array.new(rows) { Array.new(columns) }
    @carts = {}

    input.each_with_index do |line, row|
      line.chomp!
      line.each_char.with_index do |char, column|
        if char == '^'
          direction = [-1, 0]
          char = '|'
          @carts[[row, column]] = Cart.new(direction)
        elsif char == 'v'
          direction = [1, 0]
          char = '|'
          @carts[[row, column]] = Cart.new(direction)
        elsif char == '<'
          direction = [0, -1]
          char = '-'
          @carts[[row, column]] = Cart.new(direction)
        elsif char == '>'
          direction = [0, 1]
          char = '-'
          @carts[[row, column]] = Cart.new(direction)
        end
        @map[row][column] = char
      end
    end
  end

  def tick(&handle_colisions)
    @carts.sort.each do |pos, cart|
      # skip carts which collided this tick
      next unless @carts[pos]

      row, column = pos
      track = @map[row][column]
      raise "Cart out of track at #{column}#{row}" unless track

      if track == '/'
        cart.direction = [-cart.direction[1], -cart.direction[0]]
      elsif track == '\\'
        cart.direction = [cart.direction[1], cart.direction[0]]
      elsif track == '+'
        where = cart.turn!
        if where.zero? # left
          cart.direction = [-cart.direction[1], cart.direction[0]]
        elsif where == 2 # right
          cart.direction = [cart.direction[1], -cart.direction[0]]
        end
      end

      move_cart(row, column, cart, &handle_colisions)
    end
  end

  def to_s
    map.each_with_index.map do |map_row, row|
      map_row.each_with_index.map do |char, column|
        cart = @carts[[row, column]]
        if cart
          if cart.direction[0] == -1
            '^'
          elsif cart.direction[0] == 1
            'v'
          elsif cart.direction[1] == -1
            '<'
          elsif cart.direction[1] == 1
            '>'
          end
        else
          char
        end
      end.join
    end.join("\n")
  end

  private

  def move_cart(row, column, cart, &handle_colisions)
    @carts.delete([row, column])
    row2 = row + cart.direction[0]
    column2 = column + cart.direction[1]

    if @carts[[row2, column2]]
      @carts.delete([row2, column2])
      handle_colisions.call([column2, row2])
    else
      @carts[[row2, column2]] = cart
    end
  end
end

track = Track.new(ARGF.readlines)
loop do
  track.tick do |x, y|
    puts "*** colission at #{x},#{y}"
  end

  raise 'No carts left' if track.carts.length.zero?
  next unless track.carts.length == 1

  track.map.each_with_index do |map_row, row|
    map_row.each_with_index do |_, column|
      if track.carts[[row, column]]
        puts "*** last cart at #{column},#{row}"
        exit
      end
    end
  end
end
