#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'puzzle/grid'

class Word
 
  attr_reader :text, :slot
 
  def initialize word, slot, reverse
    @text, @slot, @reverse = word, slot, reverse
  end
 
  def reverse?
    @reverse
  end
 
end

class PuzzleBuilder
  
  class UsageCountArray < Array
    
    attr_accessor :usage_count
    
    def initialize *args
      super
      
      @usage_count = 0
    end

  end
  
  def initialize cols, rows
    @cols, @rows = cols, rows
    
    @cells = Array.new(@rows) { Array.new(@cols) }
  
    @solution = []
    
    cells = UsageCountArray.new(@rows) do |i| 
      Array.new(@cols) {|j|  [i, j]}
    end

    @horizontal_lines = cells
    
    @vertical_lines = UsageCountArray.new(@cols) { [] }
    
    (0...@cols).each do |col|
      (0...@rows).each do |row|
        @vertical_lines[col] << cells[row][col]
      end
    end
  
    number_diag = @rows + @cols - 1
    
    @diagonal_lines = UsageCountArray.new(number_diag) { [] }
    
    offset = @rows - 1
    
    (0...@rows).each do |row|
      
      (0...@cols).each do |col|
        @diagonal_lines[offset + col] << cells[row][col]
      end
      
      offset -= 1
      
    end
    @forward_diagonal_lines = UsageCountArray.new(number_diag) { [] }
    
    offset = 0
    
    (0...@cols).each do |col|
      
      (0...@rows).each do |row|
        @forward_diagonal_lines[offset + row] << cells[row][col]
      end
      
      offset += 1
      
    end
    
    @recently_used = []
    
    @all_line_types = [@horizontal_lines, @vertical_lines, @diagonal_lines, @forward_diagonal_lines]
    
  end
  
  def add word
  
    line_types = @all_line_types - @recently_used
    line_types = line_types.sort_by {rand}
    
    line_types.each do |lines|
      
      if add_word lines, word

        register_as_recently_used lines

        return true
        
      end
      
    end

    return false
    
  end
  
  def close
  
    letters = 'abcdefghijklmnopqrstuvwxyz'
   
    @cells.each do |line|
      line.each_index do |i|
        letter = rand(letters.length)
        line[i] = letters[letter..letter] unless line[i]
      end
    end
    
    Grid.new @cols, @rows, @horizontal_lines, @cells, @solution
    
  end
  
  def horizontal_each
    @horizontal_lines.each do |line|
      yield line
    end
  end
  
  def vertical_each
    @vertical_lines.each do |line|
      yield line
    end
  end

  def backward_diagonal_each
    @diagonal_lines.each do |line|
      yield line
    end
  end
  
  def forward_diagonal_each
    @forward_diagonal_lines.each do |line|
      yield line
    end
  end
  
  private
  
  def register_as_recently_used lines
    
    lines.usage_count += 1

    @recently_used.push lines unless @recently_used.include?(lines)

    less_used = @all_line_types.min_by {|lines| lines.usage_count}
    
    min_used_count = less_used.usage_count

    @recently_used.delete_if {|lines| lines.usage_count <= min_used_count}
    
  end
  
  def add_word lines, word
   
    lines.each do |line|
   
      slot = []
   
      line.each do |cell|
     
        if @cells[cell[0]][cell[1]]
          slot = []
        else
         
          slot << cell
         
          if slot.length == word.length
           
            reverse = rand(2) == 1
           
            @solution << Word.new(word, slot, reverse)
           
            slot = slot.reverse if reverse
             
            (0...word.length).each do |i|
              @cells[slot[i][0]][slot[i][1]] = word[i..i]
            end
           
            return true
           
          end
         
        end
       
      end
   
    end
 
    false
   
  end
  
end
  