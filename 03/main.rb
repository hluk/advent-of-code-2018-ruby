#!/usr/bin/env ruby
require_relative 'overlaps'

cuts = File.readlines('input').map { |line| Cut.new(line) }
puts overlaps(cuts)
puts nonoverlapping(cuts)
