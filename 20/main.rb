#!/usr/bin/env ruby
require 'set'
require 'rspec/core'
require 'rspec/expectations'

class Room < Hash
  def distances
    visited = Hash.new(9999999999)
    queue = [[self, 0]]
    until queue.empty?
      room, distance = queue.pop
      visited[room] = distance
      distance += 1
      queue += room.values
        .select { |next_room| distance < visited[next_room] }
        .map { |next_room| [next_room, distance] }
    end

    raise unless visited[self].zero?
    raise unless values.all? { |room1| visited[room1] == 1 }
    raise unless values.all? { |room1| room1.values.all? { |room2| room2 == self || visited[room2] == 2 } }

    visited.values
  end

  # Default hash function is extremely slow.
  def hash
    object_id
  end

  def self.create(input)
    raise unless input.start_with?('^')
    raise unless input.end_with?('$')

    result = room = Room.new
    stack = [room]

    x = 0
    y = 0
    map = { [x, y] => room }

    input.chars[1...-1].each do |chr|
      if 'WNES'.include?(chr)
        x -= 1 if chr == 'W'
        x += 1 if chr == 'E'
        y -= 1 if chr == 'N'
        y += 1 if chr == 'S'
        new_room = room[chr] = map[[x, y]] ||= Room.new
        chr2 = chr.tr('WNES', 'ESWN')
        raise unless new_room[chr2].nil? || new_room[chr2] == room

        new_room[chr2] = room
        room = new_room
      elsif chr == '|'
        room, x, y = stack.last
      elsif chr == '('
        stack.push([room, x, y])
      elsif chr == ')'
        raise if stack.length == 1

        room, x, y = stack.pop
      else
        raise "Unknown character in input: #{chr}"
      end
    end

    raise unless stack.length == 1

    result
  end
end

describe 'Rooms#create' do
  it 'create WN' do
    room = Room.create('^WN$')
    expect(room.keys).to eq(%w[W])
    expect(room['W'].keys).to eq(%w[E N])
    expect(room['W']['N'].keys).to eq(%w[S])
  end

  it 'create W((|N))' do
    room = Room.create('^W((|N))$')
    expect(room.keys).to eq(%w[W])
    expect(room['W'].keys).to eq(%w[E N])
    expect(room['W']['N'].keys).to eq(%w[S])
  end

  it 'create W(())' do
    room = Room.create('^W(())$')
    expect(room.keys).to eq(%w[W])
    expect(room['W'].keys.join).to eq('E')
  end

  it 'create ENWWW(NEEE|SSE)' do
    room = Room.create('^ENWWW(NEEE|SSE)$')
    expect(room.keys.join).to eq('E')
    expect(room['E'].keys.join).to eq('WN')
  end

  it 'can return to room' do
    room = Room.create('^WN$')
    expect(room['W']['E']).to eq(room)
  end

  it 'create SNSNSN' do
    room = Room.create('^SNSNSN$')
    expect(room.keys).to eq(%w[S])
    expect(room['S'].keys).to eq(%w[N])
    expect(room['S']['N']).to eq(room)
  end

  it 'create cycle' do
    room = Room.create('^WNES$')
    expect(room.keys).to eq(%w[W N])
    expect(room['W'].keys).to eq(%w[E N])
    expect(room['W']['N'].keys).to eq(%w[S E])
    expect(room['W']['N']['E'].keys).to eq(%w[W S])
    expect(room['W']['N']['E']['S']).to eq(room)
  end
end

describe 'Rooms#distances' do
  it 'longest distance' do
    expect(Room.create('^WNE$').distances.max).to eq(3)
    expect(Room.create('^EEE$').distances.max).to eq(3)
    expect(Room.create('^EE(E|)$').distances.max).to eq(3)
    expect(Room.create('^EE(|E)$').distances.max).to eq(3)
    expect(Room.create('^EE(|E|EE)$').distances.max).to eq(4)
    expect(Room.create('^ENWWW(NEEE|SSE(EE|N))$').distances.max).to eq(10)
    expect(Room.create('^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$').distances.max).to eq(18)
    expect(Room.create('^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$').distances.max).to eq(23)
    expect(Room.create('^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$').distances.max).to eq(31)
  end
end

exit 1 unless RSpec::Core::Runner.run([]).zero?

root = Room.create(ARGF.read.chomp)
distances = root.distances
puts(distances.max)
puts(distances.count { |distance| distance >= 1000 })
