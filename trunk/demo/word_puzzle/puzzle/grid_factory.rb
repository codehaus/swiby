#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'puzzle/distributor'
require 'puzzle/puzzle_builder'

class GridFactory
  
  def initialize
    @dist = WordDistributor.new
    @dist.load 'words_en.txt'
  end
  
  def create cols = 10, rows = 10

    @dist.reset
    
    builder = PuzzleBuilder.new(cols, rows)

    while not @dist.empty?

      word = @dist.draw
      
      if not builder.add(word)
        @dist.filter_out(word.length)
      end
      
    end

    builder.close
    
  end
  
  def change_language lang
    
      raise "Unsupported language #{lang}" unless lang == :en or lang == :fr
        
      @dist.load "words_#{lang}.txt"
      
  end
  
end
