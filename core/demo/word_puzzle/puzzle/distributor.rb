#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class WordDistributor

  def initialize
    @words = []
  end
   
  def load file
 
    File.readlines(file).each do |line|
      line = line.chomp
      line.tr! 'באגהיטךכםלמןףעפצתשûüח', 'aaaaeeeeiiiioooouuuuc'
      @words << line if line.length > 2
    end
 
    @original = Array.new(@words)
    
  end

  def draw
   
    i = rand(@words.length - 1)
   
    @words.delete_at(i)
   
  end

  def filter_out length
    @words.delete_if {|w| w.length >= length}
  end

  def empty?
    @words.empty?
  end
  
  def reset
    @words = Array.new(@original)
  end
  
end
