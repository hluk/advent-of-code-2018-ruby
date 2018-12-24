#!/usr/bin/env ruby
require 'set'
require 'rspec/core'
require 'rspec/expectations'

IMMUNE_TO = 'immune to '.freeze
WEAK_TO = 'weak to '.freeze

class UnitGroup
  attr_accessor :army_name
  attr_accessor :count
  attr_accessor :hit_points
  attr_accessor :attack_damage
  attr_accessor :attack_type
  attr_accessor :initiative
  attr_accessor :weaknesses
  attr_accessor :immunities
  attr_accessor :target
  attr_accessor :targets

  def initialize
    @immunities = []
    @weaknesses = []
  end

  def effective_power
    @count * @attack_damage
  end

  def self.from_input(army_name, input)
    /(?<count>\d+) units each with (?<hit_points>\d+) hit points (\((?<attributes>[^)]*)\) )?with an attack that does (?<attack_damage>\d+) (?<attack_type>\w+) damage at initiative (?<initiative>\d+)/ =~ input

    group = UnitGroup.new
    group.army_name = army_name
    group.count = count.to_i
    group.hit_points = hit_points.to_i
    group.attack_damage = attack_damage.to_i
    group.attack_type = attack_type
    group.initiative = initiative.to_i

    if attributes
      attributes = attributes.split('; ')
      attributes.each do |attribute|
        if attribute.start_with?(IMMUNE_TO)
          group.immunities = attribute[IMMUNE_TO.length..-1].split(', ')
        elsif attribute.start_with?(WEAK_TO)
          group.weaknesses = attribute[WEAK_TO.length..-1].split(', ')
        else
          raise "Unknown attributes: #{attribute}"
        end
      end
    end

    group
  end

  def to_s
    "<#{@army_name}-#{@initiative}" \
      " #{@count}*#{@attack_damage}#{@attack_type[0]}" \
      " #{@hit_points}" \
      "+#{@immunities.map { |i| i[0] }.join}" \
      "-#{@weaknesses.map { |w| w[0] }.join}" \
      '>'
  end

  def target_selection_priority
    [-effective_power, -@initiative]
  end

  def attack
    return if @count.zero? || @target.nil?

    damage = damage_amount(@target)
    killed_units = [damage / @target.hit_points, @target.count].min
    @target.count -= killed_units
  end

  def pick_target(targets)
    raise if @count <= 0

    enemies = targets.reject { |group| group.army_name == @army_name || group.immunities.include?(@attack_type) }
    @target = enemies.max_by do |group|
      [
        damage_amount(group),
        group.effective_power,
        group.initiative
      ]
    end
    targets.delete(@target)
  end

  def damage_amount(group)
    raise if @count <= 0

    return 0 if group.immunities.include?(@attack_type)

    group.weaknesses.include?(@attack_type) ? effective_power * 2 : effective_power
  end
end

class Battle
  attr_accessor :groups

  def initialize
    @groups = []
    @round = 0
  end

  def fight
    @round += 1

    target_selection_phase
    attacking_phase

    @groups.delete_if { |group| group.count.zero? }
  end

  def to_s
    "Battle (round=#{@round}):\n  " + @groups.map(&:to_s).join("\n  ")
  end

  def target_selection_phase
    targets = @groups.clone
    @groups.sort_by(&:target_selection_priority).each do |group|
      group.pick_target(targets)
    end
  end

  def attacking_phase
    @groups.each(&:attack)
  end

  def boost(army_name, attack_damage_boost)
    @groups.each do |group|
      group.attack_damage += attack_damage_boost if army_name == group.army_name
    end
  end

  def self.from_input(input)
    battle = Battle.new
    army_name = nil

    input.each do |line|
      ln = line.chomp
      next if ln.empty?

      if ln.chomp.end_with?(':')
        army_name = ln[0...-1]
      else
        raise unless army_name

        group = UnitGroup.from_input(army_name, ln)
        battle.groups.push(group)
      end
    end

    battle.groups.sort_by!(&:initiative).reverse!
    battle
  end

  def winner?
    return nil if @round.zero?

    army_name = @groups[0].army_name
    count = @groups.count { |group| group.army_name == army_name }

    return army_name if count == @groups.length

    return 'STALEMATE' if @groups.all? { |group| group.target.nil? }
  end

  def unit_count
    @groups.sum(&:count)
  end
end

describe UnitGroup do
  it 'read from input' do
    group = UnitGroup.from_input(
      'test',
      '18 units each with 729 hit points (weak to fire; immune to cold, slashing)' \
      ' with an attack that does 8 radiation damage at initiative 10'
    )
    expect(group.count).to eq(18)
    expect(group.hit_points).to eq(729)
    expect(group.attack_damage).to eq(8)
    expect(group.effective_power).to eq(144)
    expect(group.initiative).to eq(10)
    expect(group.weaknesses).to eq(%w[fire])
    expect(group.immunities).to eq(%w[cold slashing])
  end
end

describe Battle do
  before(:example) do
    @input = File.readlines('input_test')
  end

  it 'read from input' do
    battle = Battle.from_input(@input)
    expect(battle.groups.length).to eq(4)
    expect(battle.groups.group_by(&:army_name).length).to eq(2)

    group1 = battle.groups[2]
    expect(group1.initiative).to eq(2)
    expect(group1.army_name).to eq('Immune System')
    expect(group1.count).to eq(17)
    expect(group1.hit_points).to eq(5390)
    expect(group1.weaknesses).to eq(%w[radiation bludgeoning])
    expect(group1.immunities).to eq(%w[])
    expect(group1.attack_damage).to eq(4507)
    expect(group1.attack_type).to eq('fire')

    group4 = battle.groups[0]
    expect(group4.initiative).to eq(4)
    expect(group4.army_name).to eq('Infection')
    expect(group4.count).to eq(4485)
    expect(group4.hit_points).to eq(2961)
    expect(group4.weaknesses).to eq(%w[fire cold])
    expect(group4.immunities).to eq(%w[radiation])
    expect(group4.attack_damage).to eq(12)
    expect(group4.attack_type).to eq('slashing')
  end

  it 'fights' do
    battle = Battle.from_input(@input)
    group1 = battle.groups[2]
    group2 = battle.groups[1]
    group3 = battle.groups[3]
    group4 = battle.groups[0]
    expect(group1.count).to eq(17)
    expect(group2.count).to eq(989)
    expect(group3.count).to eq(801)
    expect(group4.count).to eq(4485)

    battle.fight

    expect(group1.count).to eq(0)
    expect(group2.count).to eq(905)
    expect(group3.count).to eq(797)
    expect(group4.count).to eq(4434)
    expect(battle.winner?).to eq(nil)

    battle.fight

    expect(group1.count).to eq(0)
    expect(group2.count).to eq(761)
    expect(group3.count).to eq(793)
    expect(group4.count).to eq(4434)
    expect(battle.winner?).to eq(nil)

    battle.fight

    expect(group1.count).to eq(0)
    expect(group2.count).to eq(618)
    expect(group3.count).to eq(789)
    expect(group4.count).to eq(4434)
    expect(battle.winner?).to eq(nil)

    battle.fight

    expect(group1.count).to eq(0)
    expect(group2.count).to eq(475)
    expect(group3.count).to eq(786)
    expect(group4.count).to eq(4434)
    expect(battle.winner?).to eq(nil)

    battle.fight

    expect(group1.count).to eq(0)
    expect(group2.count).to eq(333)
    expect(group3.count).to eq(784)
    expect(group4.count).to eq(4434)
    expect(battle.winner?).to eq(nil)

    battle.fight

    expect(group1.count).to eq(0)
    expect(group2.count).to eq(191)
    expect(group3.count).to eq(783)
    expect(group4.count).to eq(4434)
    expect(battle.winner?).to eq(nil)

    battle.fight

    expect(group1.count).to eq(0)
    expect(group2.count).to eq(49)
    expect(group3.count).to eq(782)
    expect(group4.count).to eq(4434)
    expect(battle.winner?).to eq(nil)

    battle.fight

    expect(group1.count).to eq(0)
    expect(group2.count).to eq(0)
    expect(group3.count).to eq(782)
    expect(group4.count).to eq(4434)
    expect(battle.winner?).to eq('Infection')

    expect(battle.unit_count).to eq(5216)
  end

  it 'boost' do
    win_boost = 1570
    battle = Battle.from_input(@input)
    battle.boost('Immune System', win_boost)

    group1 = battle.groups[2]
    group2 = battle.groups[1]
    group3 = battle.groups[3]
    group4 = battle.groups[0]

    expect(group1.army_name).to eq('Immune System')
    expect(group1.attack_damage).to eq(4507 + win_boost)

    expect(group2.army_name).to eq('Immune System')
    expect(group2.attack_damage).to eq(25 + win_boost)

    expect(group1.count).to eq(17)
    expect(group2.count).to eq(989)
    expect(group3.count).to eq(801)
    expect(group4.count).to eq(4485)

    battle.fight

    expect(group1.count).to eq(8)
    expect(group2.count).to eq(905)
    expect(group3.count).to eq(466)
    expect(group4.count).to eq(4453)
    expect(battle.winner?).to eq(nil)

    battle.fight

    expect(group1.count).to eq(0)
    expect(group2.count).to eq(876)
    expect(group3.count).to eq(160)
    expect(group4.count).to eq(4453)
    expect(battle.winner?).to eq(nil)

    battle.fight until battle.winner? || group2.count == 64

    expect(battle.winner?).to eq(nil)
    expect(group3.count).to eq(19)
    expect(group4.count).to eq(214)

    battle.fight

    expect(battle.winner?).to eq(nil)
    expect(group2.count).to eq(60)
    expect(group3.count).to eq(19)
    expect(group4.count).to eq(182)

    battle.fight

    expect(battle.winner?).to eq(nil)
    expect(group2.count).to eq(60)
    expect(group3.count).to eq(0)
    expect(group4.count).to eq(182)

    battle.fight until battle.winner?
    expect(battle.winner?).to eq('Immune System')
    expect(battle.unit_count).to eq(51)
  end
end

def profile
  require 'ruby-prof'
  RubyProf.start

  input = ARGF.readlines
  battle = Battle.from_input(input)
  i = 0
  battle.fight until battle.winner? || (i += 1) > 10000

  result = RubyProf.stop
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(STDOUT)
  exit
end

#profile

exit 1 unless RSpec::Core::Runner.run([]).zero?

input = ARGF.readlines

battle = Battle.from_input(input)
battle.fight until battle.winner?
raise "Unexpected outcome: #{battle.winner?}, #{battle}" unless battle.winner? == 'Infection'

part1 = battle.unit_count
puts part1
raise 'Too low' if part1 <= 9993

boost = 1
loop do
  battle = Battle.from_input(input)
  battle.boost('Immune System', boost)
  battle.fight until battle.winner?

  puts "#{boost} #{battle.winner?}"
  break if battle.winner? == 'Immune System'

  boost += 1
end

part2 = battle.unit_count
puts part2
