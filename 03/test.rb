require 'test/unit'
require_relative 'overlaps'

class TestBitArray < Test::Unit::TestCase
  def test_unset_initially
    b = BitArray.new

    assert b.unset?(0)
    assert b.unset?(1)
    assert b.unset?(100)

    refute b.set?(0)
    refute b.set?(1)
    refute b.set?(100)
  end

  def test_set_first_bit
    b = BitArray.new
    assert b.set(0)

    refute b.unset?(0)
    assert b.unset?(1)
    assert b.unset?(100)

    assert b.set?(0)
    refute b.set?(1)
    refute b.set?(100)
  end

  def test_set_second_bit
    b = BitArray.new
    assert b.set(1)

    assert b.unset?(0)
    refute b.unset?(1)
    assert b.unset?(2)
    assert b.unset?(100)

    refute b.set?(0)
    assert b.set?(1)
    refute b.set?(2)
    refute b.set?(100)
  end
end

class TestCuts < Test::Unit::TestCase
  def test_cut_new
    cut = Cut.new('#100 @ 200,300: 400x500')
    assert_equal 100, cut.id
    assert_equal 200, cut.left
    assert_equal 300, cut.top
    assert_equal 400, cut.width
    assert_equal 500, cut.height
  end
end

class TestOverlaps < Test::Unit::TestCase
  def test_overlaps_none
    assert_equal 0, overlaps([])
  end

  def test_overlaps_none_with_cuts
    cuts = [
      Cut.new('#1 @ 1,1: 1x1'),
      Cut.new('#2 @ 1,2: 1x1')
    ]
    assert_equal 0, overlaps(cuts)
  end

  def test_overlaps_single
    cuts = [
      Cut.new('#1 @ 1,1: 1x1'),
      Cut.new('#2 @ 1,1: 1x1')
    ]
    assert_equal 1, overlaps(cuts)
  end

  def test_overlaps_single_more
    cuts = [
      Cut.new('#1 @ 1,1: 1x1'),
      Cut.new('#2 @ 1,1: 1x1'),
      Cut.new('#3 @ 1,1: 1x1')
    ]
    assert_equal 1, overlaps(cuts)
  end

  def test_overlaps_single_bottom_right_corner
    cuts = [
      Cut.new('#1 @ 1,1: 2x2'),
      Cut.new('#2 @ 2,2: 1x1')
    ]
    assert_equal 1, overlaps(cuts)
  end

  def test_overlaps_multiple_bottom_more
    cuts = [
      Cut.new('#1 @ 1,1: 2x2'),
      Cut.new('#2 @ 2,2: 1x1'),
      Cut.new('#3 @ 1,2: 1x1')
    ]
    assert_equal 2, overlaps(cuts)
  end
end
