require 'scanf'

class BitArray
  def initialize
    @mask = 0
  end

  def set(position)
    @mask |= (1 << position)
  end

  def reset(position)
    @mask ^= (1 << position)
  end

  def set?(position)
    @mask[position].nonzero?
  end

  def unset?(position)
    @mask[position].zero?
  end

  def to_s
    @mask.to_s(2)
  end
end

class Cut
  attr_accessor :id, :left, :top, :width, :height

  def initialize(line)
    @id, @left, @top, @width, @height = line.scanf('#%d @ %d,%d: %dx%d\n')
  end

  def to_s
    "##{@id} @ #{@left},#{@top}: #{@width} #{@height}"
  end
end

def overlaps(cuts)
  fabric1 = Array.new(1001) { BitArray.new }
  fabric2 = Array.new(1001) { BitArray.new }
  overlaps = 0

  cuts.each do |cut|
    (cut.top...cut.top + cut.height).each do |row|
      row1 = fabric1[row]
      row2 = fabric2[row]

      (cut.left...cut.left + cut.width).each do |col|
        if row1.unset?(col)
          row1.set(col)
        elsif row2.unset?(col)
          row2.set(col)
          overlaps += 1
        end
      end
    end
  end

  overlaps
end

def nonoverlapping(cuts)
  fabric1 = Array.new(1001) { BitArray.new }
  fabric2 = Array.new(1001) { BitArray.new }

  cuts.each do |cut|
    (cut.top...cut.top + cut.height).each do |row|
      row1 = fabric1[row]
      row2 = fabric2[row]

      (cut.left...cut.left + cut.width).each do |col|
        if row1.unset?(col)
          row1.set(col)
        elsif row2.unset?(col)
          row2.set(col)
        end
      end
    end
  end

  cuts.find do |cut|
    (cut.top...cut.top + cut.height).all? do |row|
      (cut.left...cut.left + cut.width).all? { |col| fabric2[row].unset?(col) }
    end
  end
end

