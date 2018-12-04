class Guard
  attr_reader :slept

  def initialize
    @slept = 0
    @sleep = []
    @sleeps = Array.new(60, 0)
  end

  def sleep(minute)
    @sleep.append([minute, 59])
  end

  def wake(minute)
    return if @sleep.empty?

    @sleep.last[1] = minute

    sleep_since_minute = @sleep.last[0]
    update_sleep(sleep_since_minute, minute)
  end

  def sleepy_minute
    @sleeps.each_with_index.max
  end

  private

  def update_sleep(from, to)
    @slept += to - from

    (from...to).each do |minute|
      @sleeps[minute] += 1
    end
  end
end

def get_minute(text)
  match_data = /:(\d+)/.match(text)
  match_data[1].to_i
end

def get_guards(enum)
  guards = Hash.new { |hash, key| hash[key] = Guard.new }
  guard = nil

  enum.sort.each do |line|
    date, time, text = line.split(' ', 3)
    if text.start_with?('Guard')
      match_data = /\d+/.match(text)
      guard_id = match_data[0].to_i
      puts "-- Guard #{guard_id}"
      guard = guards[guard_id]
    elsif guard && text.start_with?('falls')
      minute = get_minute(time)
      guard.sleep(minute)
      puts "- sleep #{minute}"
    elsif guard && text.start_with?('wakes')
      minute = get_minute(time)
      guard.wake(minute)
      puts "- wake #{minute}, slept #{guard.slept}, sleepy minute #{guard.sleepy_minute}"
    else
      raise "Unrecognized text: #{text}"
    end
  end

  guards
end

def get_sleepy_guard(guards)
  guards.max_by { |_, v| v.slept }[0]
end

def get_sleepy_guard2(guards)
  guards.max_by { |_, v| v.sleepy_minute[0] }[0]
end
