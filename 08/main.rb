#!/usr/bin/env ruby
require 'ostruct'

class Node
  attr_accessor :nodes
  attr_accessor :data

  def initialize
    @nodes = []
    @data = []
  end

  def sum
    @data.sum + @nodes.map(&:sum).sum
  end

  def value
    return @data.sum if @nodes.empty?

    @data
      .map { |n| @nodes[n - 1] }
      .compact
      .map(&:value)
      .sum
  end

  def build_tree(input)
    stack = []
    read_header(input, stack)

    until stack.empty?
      until stack.last.node_count.zero?
        node = Node.new
        stack.last.node.nodes.append(node)
        stack.last.node_count -= 1
        node.read_header(input, stack)
      end

      stack.last.node.data = input.take(stack.last.data_count)
      input.slice!(0...stack.last.data_count)

      stack.pop
    end
  end

  protected

  def read_header(input, stack)
    stack.append(OpenStruct.new(node_count: input[0], data_count: input[1], node: self))
    input.slice!(0..1)
  end
end

input = ARGF.read.split(' ').map(&:to_i)

tree = Node.new
tree.build_tree(input)
puts tree.sum

puts tree.value
