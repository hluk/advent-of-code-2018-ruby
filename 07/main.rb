#!/usr/bin/env ruby
require 'set'
require 'ostruct'

WORKERS = 5

def part1(nodes, all_nodes)
  result = ''
  until all_nodes.empty?
    first_node = all_nodes.find { |node| nodes[node].empty? }
    all_nodes.delete(first_node)
    nodes.each { |_, sub_steps| sub_steps.delete(first_node) }
    result += first_node
  end
  result
end

def part2(nodes, all_nodes)
  seconds = 0
  workers = []

  until all_nodes.empty? && workers.empty?
    (WORKERS - workers.length).times do
      available_node = all_nodes.find { |node| nodes[node].empty? }
      break unless available_node

      all_nodes.delete(available_node)
      node_seconds = available_node.bytes[0] - 'A'.bytes[0] + 1 + 60
      workers.append(OpenStruct.new(node: available_node, seconds: node_seconds))
    end

    skip_seconds = workers.min_by(&:seconds).seconds

    workers.each do |worker|
      worker.seconds -= skip_seconds
      nodes.each { |_, sub_steps| sub_steps.delete(worker.node) } if worker.seconds.zero?
    end
    workers.delete_if { |worker| worker.seconds.zero? }

    seconds += skip_seconds
  end

  seconds
end

steps = ARGF.readlines.map { |line| [line[5], line[36]] }
steps.sort!
all_nodes = Set.new(steps.flatten).sort.to_set

nodes = Hash.new { |hash, key| hash[key] = Set.new }
steps.each { |a, b| nodes[b].add(a) }
puts part1(nodes.clone, all_nodes.clone)

nodes.clear
steps.each { |a, b| nodes[b].add(a) }
puts part2(nodes.clone, all_nodes.clone)
