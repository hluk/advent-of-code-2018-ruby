#!/usr/bin/env ruby
require_relative 'guard'

guards = get_guards(File.readlines('input'))

sleepy_guard_id = get_sleepy_guard(guards)
sleepy_minute = guards[sleepy_guard_id].sleepy_minute[1]
puts sleepy_guard_id, sleepy_minute, sleepy_guard_id * sleepy_minute

sleepy_guard_id = get_sleepy_guard2(guards)
sleepy_minute = guards[sleepy_guard_id].sleepy_minute[1]
puts sleepy_guard_id, sleepy_minute, sleepy_guard_id * sleepy_minute
