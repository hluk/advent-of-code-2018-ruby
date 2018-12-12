#!/usr/bin/env ruby
require 'rspec/core'
require 'rspec/expectations'

class Pots
  attr_reader :first_pot_index
  attr_reader :pots

  def initialize(input)
    @pots = ''
    @mutations = Hash.new

    initial_state_prefix = 'initial state: '.freeze
    input.each do |line|
      line.chomp!
      next if line.empty?

      if line.start_with?(initial_state_prefix)
        @pots = line[initial_state_prefix.length..-1]
      else
        @mutations[line[0..4]] = line[-1]
      end
    end

    @first_pot_index = 0
  end

  def next_generation
    @pots.prepend('....')
    @first_pot_index += 4
    @pots += '....' if @pots[-4..-1] != '....'

    new_pots = '.' * @pots.length
    (0...@pots.length - 5).each do |i|
      current_pots = @pots[i...i + 5]
      mutate = @mutations[current_pots]
      new_pots[i + 2] = mutate if mutate
    end

    @pots = new_pots

    prefix = @pots.each_char.take_while { |x| x == '.' }.count
    @pots[0...prefix] = ''
    @first_pot_index -= prefix
    @pots[-1] = '' while @pots[-1] == '.'

    @pots
  end

  def next_generations(count)
    cache = []
    cache_indexes = Hash.new

    count.times do |generation|
      if cache_indexes[@pots]
        first_index = cache_indexes[@pots]
        loop_ = cache[first_index..-1]
        generations_to_go = count - generation
        loop_count, rest = generations_to_go.divmod(loop_.length)
        index_diff1 = loop_[0...rest].sum { |_, index_diff| index_diff }
        index_diff2 = loop_[rest..-1].sum { |_, index_diff| index_diff }
        @first_pot_index += (index_diff1 + index_diff2) * loop_count + index_diff1 * rest
        break
      end

      old_pots = @pots.clone
      old_first_pot_index = @first_pot_index

      next_generation

      cache_indexes[old_pots] = cache.length
      cache.append([@pots, @first_pot_index - old_first_pot_index])
    end

    @pots
  end

  def sum
    @pots.chars.each_with_index.sum { |pot, i| pot == '#' ? i - @first_pot_index : 0 }
  end
end

RSpec.describe '#next_generation' do
  it 'returns next generation' do
    pots = Pots.new(File.readlines('input_test'))
    expect(pots.pots).to eq('#..#.#..##......###...###')
    expect(pots.first_pot_index).to eq(0)

    expect(pots.next_generation).to eq('#...#....#.....#..#..#..#')
    expect(pots.first_pot_index).to eq(0)

    expect(pots.next_generation).to eq('##..##...##....#..#..#..##')
    expect(pots.first_pot_index).to eq(0)

    expect(pots.next_generation).to eq('#.#...#..#.#....#..#..#...#')
    expect(pots.first_pot_index).to eq(1)
  end

  it 'returns sum' do
    pots = Pots.new(File.readlines('input_test'))
    expect(pots.next_generations(20)).to eq('#....##....#####...#######....#.#..##')
    expect(pots.sum).to eq(325)
  end
end

exit 1 unless RSpec::Core::Runner.run([]).zero?

pots = Pots.new(File.readlines('input'))
pots.next_generations(20)
puts pots.sum

pots = Pots.new(File.readlines('input'))
pots.next_generations(50000000000)
puts pots.sum
