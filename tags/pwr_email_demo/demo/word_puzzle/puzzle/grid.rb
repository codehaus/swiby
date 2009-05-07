#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class Grid

  attr_reader :cols, :rows
  
  def initialize cols, rows, lines, cells, solution
    @lines = lines
    @cols, @rows = cols, rows
    @cells, @solution = cells, solution
  end
  
  def [] row, col
    @cells[row][col]
  end
  
  def each_line
    @lines.each do |line|
      yield line
    end
  end
  
  def each_word
    @solution.each do |word|
      yield word
    end
  end
  
end