#!/usr/bin/env ruby
require 'rspec/core'
require 'rspec/expectations'

class Recipes
  def initialize(recipes = [3, 7])
    @recipes = recipes
    @elf1 = 0
    @elf2 = 1
  end

  def scores_after(recipe_count, take_n = 10)
    max_recipe_count = recipe_count + take_n
    make while @recipes.length < max_recipe_count
    @recipes[recipe_count...max_recipe_count].map(&:to_s).join
  end

  def make
    recipe1 = @recipes[@elf1]
    recipe2 = @recipes[@elf2]
    recipe = recipe1 + recipe2
    if recipe < 10
      @recipes.push(recipe)
    else
      @recipes.push(1, recipe - 10)
    end
    @elf1 = (@elf1 + recipe1 + 1) % @recipes.length
    @elf2 = (@elf2 + recipe2 + 1) % @recipes.length
  end

  def count_left_of(right_recipes)
    find_from = 0
    loop do
      found_index = @recipes[find_from..-1].map(&:to_s).join.index(right_recipes)
      return find_from + found_index if found_index

      find_from = [@recipes.length - right_recipes.length, 0].max
      100000.times { make }
    end
  end
end

RSpec.describe 'Recipes#scores_after' do
  it 'returns scores after' do
    recipes = Recipes.new
    expect(recipes.scores_after(5)).to eq('0124515891')
    expect(recipes.scores_after(9)).to eq('5158916779')
    expect(recipes.scores_after(18)).to eq('9251071085')
    expect(recipes.scores_after(2018)).to eq('5941429882')
  end
end

RSpec.describe 'Recipes#count_left_of' do
  it 'returns count left of' do
    recipes = Recipes.new
    expect(recipes.count_left_of('01245')).to eq(5)
    expect(recipes.count_left_of('51589')).to eq(9)
    expect(recipes.count_left_of('92510')).to eq(18)
    expect(recipes.count_left_of('59414')).to eq(2018)
  end
end

#require 'ruby-prof'
#RubyProf.start
#puts Recipes.new.count_left_of('99999')
#result = RubyProf.stop
#printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT)

exit 1 unless RSpec::Core::Runner.run([]).zero?

recipes = Recipes.new
puts recipes.scores_after(84601)
puts recipes.count_left_of('084601')
