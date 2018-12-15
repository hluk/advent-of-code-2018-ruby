#!/usr/bin/env ruby
require 'set'

DIRECTIONS = [[-1, 0], [0, -1], [0, 1], [1, 0]].freeze

class Actor
  attr_accessor :row
  attr_accessor :column
  attr_accessor :is_elf
  attr_accessor :hit_points
  attr_accessor :power

  def initialize(row, column, is_elf)
    @row = row
    @column = column
    @is_elf = is_elf
    @hit_points = 200
    @power = 3
  end

  def to_s
    "#{char}(#{@hit_points})"
  end

  def char
    @is_elf ? 'E' : 'G'
  end
end

class Battle
  attr_accessor :map
  attr_accessor :actors
  attr_accessor :current

  def initialize(input, elf_power = 3)
    @map = {}
    @actors = {}

    input.each.with_index do |line, row|
      line.chomp.each_char.with_index do |char, column|
        if char == '.'
          @map[[row, column]] = char
        elsif 'GE'.include?(char)
          actor = Actor.new(row, column, char == 'E')
          actor.power = elf_power if actor.is_elf
          @actors[[row, column]] = actor
          @map[[row, column]] = char
        elsif char != '#'
          raise "Unknown map character #{char}"
        end
      end
    end
  end

  def tick
    return true if @actors.empty?

    @actors.sort.each do |_, actor|
      return true if finished?

      next unless actor.hit_points > 0

      raise if @map[[actor.row, actor.column]] != actor.char

      row, column = find_nearest_target(actor)
      move_to(actor, row, column) if row && @map[[row, column]] == '.'
      attack(actor)

      raise if @map[[actor.row, actor.column]] != actor.char
    end

    false
  end

  def attack(actor)
    target = find_weakest_target(actor)
    return unless target

    result = "ATTACK #{actor} -> #{target}"
    target.hit_points -= actor.power
    puts result + " -> #{target}"
    kill(target) if target.hit_points <= 0
  end

  def next_to?(actor, row, column)
    DIRECTIONS.any? do |d_row, d_column|
      actor.row + d_row == row && actor.column + d_column == column
    end
  end

  def find_weakest_target(actor)
    row, column = DIRECTIONS.min_by do |row, column|
      target = @actors[[actor.row + row, actor.column + column]]
      (target && target.is_elf != actor.is_elf) ? target.hit_points : 999999
    end

    target = @actors[[actor.row + row, actor.column + column]]
    target.nil? || target.is_elf == actor.is_elf ? nil : target
  end

  def find_nearest_target(actor)
    visited = Set.new
    queue = []

    DIRECTIONS.each do |row, column|
      new_pos = [actor.row + row, actor.column + column]
      queue.push([new_pos, new_pos, 0])
      visited.add(new_pos)
    end

    found_position = [999999, 999999]
    found_distance = 9999999
    found_first_pos = nil

    until queue.empty?
      pos, first_pos, distance = queue.shift
      next if found_distance < distance

      target = @actors[pos]
      if target && target.is_elf != actor.is_elf && (distance < found_distance || (pos <=> found_position) == -1)
        found_position = pos
        found_distance = distance
        found_first_pos = first_pos
      end

      next if found_distance <= distance
      next unless @map[pos] == '.'

      DIRECTIONS.each do |next_pos|
        new_pos = [pos[0] + next_pos[0], pos[1] + next_pos[1]]
        next if visited.include?(new_pos)

        queue.push([new_pos, first_pos, distance + 1])
        visited.add(new_pos)
      end
    end

    found_first_pos
  end

  def move_to(actor, row, column)
    raise if @actors[[actor.row, actor.column]] != actor
    raise if @map[[row, column]] != '.'

    @actors.delete([actor.row, actor.column])
    @map[[actor.row, actor.column]] = '.'

    puts "MOVE #{actor}"
    actor.row = row
    actor.column = column

    @map[[actor.row, actor.column]] = actor.char
    @actors[[actor.row, actor.column]] = actor

    raise if @map[[row, column]] != actor.char
  end

  def kill(target)
    raise if @actors[[target.row, target.column]] != target
    raise if @map[[target.row, target.column]] != target.char

    @map[[target.row, target.column]] = '.'
    @actors.delete([target.row, target.column])

    puts "KILL #{target} at #{[target.row, target.column]}"
  end

  def elf_count
    @actors.each_value.count(&:is_elf)
  end

  def finished?
    count = elf_count
    count.zero? || count == @actors.length
  end

  def victory?
    @elf_count == @actors.length
  end

  def to_s
    row = 0
    column = -1
    result = ''
    @map.sort.each do |pos, value|
      column += 1

      if pos[0] != row
        result += "#\n" * (pos[0] - row)
        row = pos[0]
        column = 0
      end

      result += '#' * (pos[1] - column)
      column = pos[1]

      result += value
    end

    result += "#\n---\n"
  end
end

def part1(input)
  battle = Battle.new(input)
  puts battle
  rounds = 0
  loop do
    puts '----------'
    puts "ROUND: #{rounds + 1}"
    finished = battle.tick
    puts battle
    battle.actors.sort.each do |_, actor|
      puts "#{actor.char}(#{actor.hit_points})"
    end

    break if finished

    rounds += 1
  end

  puts "Rounds: #{rounds}"

  total_hit_points = battle.actors.each_value.sum(&:hit_points)
  puts "Total hit points: #{total_hit_points}"

  puts rounds * total_hit_points

  raise 'bad result' if rounds * total_hit_points != 195774
end

def part2(input)
  win_elf_power = 99
  battle = Battle.new(input, win_elf_power)
  elf_count = battle.elf_count
  until battle.tick
  end
  raise if elf_count != battle.elf_count

  loose_elf_power = 3

  until loose_elf_power + 1 == win_elf_power do
    elf_power = loose_elf_power + (win_elf_power - loose_elf_power) / 2
    battle = Battle.new(input, elf_power)
    elf_count = battle.elf_count
    rounds = 0
    until battle.tick || elf_count != battle.elf_count
      rounds += 1
    end

    p elf_power, elf_count == battle.elf_count
    if elf_count == battle.elf_count
      win_elf_power = elf_power
    else
      loose_elf_power = elf_power
    end
  end

  puts "Rounds: #{rounds}"

  total_hit_points = battle.actors.each_value.sum(&:hit_points)
  puts "Total hit points: #{total_hit_points}"

  puts rounds * total_hit_points
end

input = ARGF.readlines
#part1(input)
part2(input)
