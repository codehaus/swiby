#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'test/unit'
require 'puzzle/puzzle_builder'

class TestPuzzleBuilder < Test::Unit::TestCase

  def test_horizontal_each
    
    builder = PuzzleBuilder.new(4, 3)
    
    builder.horizontal_each do |line|
      
      assert_equal 4, line.length
      
      assert_equal 0, line[0][1]
      assert_equal 1, line[1][1]
      assert_equal 2, line[2][1]
      assert_equal 3, line[3][1]
      
    end
    
  end
  
  def test_vertical_each
    
    builder = PuzzleBuilder.new(4, 3)
    
    builder.vertical_each do |line|
      
      assert_equal 3, line.length
      
      assert_equal 0, line[0][0]
      assert_equal 1, line[1][0]
      assert_equal 2, line[2][0]
      
    end
    
  end
  
  def test_backward_diagonal_each_5_x_4
  
    builder = PuzzleBuilder.new(5, 4)
    
    lines = []
    
    builder.backward_diagonal_each do |line|
      lines << line
    end

    assert_equal                         [[3, 0]], lines[0]
    assert_equal                 [[2, 0], [3, 1]], lines[1]
    assert_equal         [[1, 0], [2, 1], [3, 2]], lines[2]
    assert_equal [[0, 0], [1, 1], [2, 2], [3, 3]], lines[3]
    assert_equal [[0, 1], [1, 2], [2, 3], [3, 4]], lines[4]
    assert_equal [[0, 2], [1, 3], [2, 4]]        , lines[5]
    assert_equal [[0, 3], [1, 4]]                , lines[6]
    assert_equal [[0, 4]]                        , lines[7]
    
  end
  
  def test_backward_diagonal_each_4_x_5
    
    builder = PuzzleBuilder.new(4, 5)
    
    lines = []
    
    builder.backward_diagonal_each do |line|
      lines << line
    end

    assert_equal                         [[4, 0]], lines[0]
    assert_equal                 [[3, 0], [4, 1]], lines[1]
    assert_equal         [[2, 0], [3, 1], [4, 2]], lines[2]
    assert_equal [[1, 0], [2, 1], [3, 2], [4, 3]], lines[3]
    assert_equal [[0, 0], [1, 1], [2, 2], [3, 3]], lines[4]
    assert_equal [[0, 1], [1, 2], [2, 3]]        , lines[5]
    assert_equal [[0, 2], [1, 3]]                , lines[6]
    assert_equal [[0, 3]]                        , lines[7]
    
  end
  
  def test_backward_diagonal_each_2_x_5
    
    builder = PuzzleBuilder.new(2, 5)
    
    lines = []
    
    builder.backward_diagonal_each do |line|
      lines << line
    end

    assert_equal                                 [[4, 0]], lines[0]
    assert_equal                         [[3, 0], [4, 1]], lines[1]
    assert_equal                 [[2, 0], [3, 1]]        , lines[2]
    assert_equal         [[1, 0], [2, 1]]                , lines[3]
    assert_equal [[0, 0], [1, 1]]                        , lines[4]
    assert_equal [[0, 1]]                                , lines[5]
    
  end

  def test_forward_diagonal_each_5_x_4
  
    builder = PuzzleBuilder.new(5, 4)
    
    lines = []
    
    builder.forward_diagonal_each do |line|
      lines << line
    end

    assert_equal [[0,0]]                            , lines[0]
    assert_equal [[1,0], [0,1]]                     , lines[1]
    assert_equal [[2,0], [1,1], [0,2]]              , lines[2]
    assert_equal [[3,0], [2,1], [1,2], [0,3]]       , lines[3]
    assert_equal        [[3,1], [2,2], [1,3], [0,4]], lines[4]
    assert_equal               [[3,2], [2,3], [1,4]], lines[5]
    assert_equal                      [[3,3], [2,4]], lines[6]
    assert_equal                             [[3,4]], lines[7]
    
  end
end