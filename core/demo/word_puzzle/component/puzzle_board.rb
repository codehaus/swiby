#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import javax.swing.Timer
import java.awt.Dimension

class PuzzleBoard
  
  WIDTH = 30
  HEIGHT = 30
  DEFAULT_MARGIN = 10
  
  def initialize panel, grid, &listener
    
    @listener = listener
    
    @panel,  @grid = panel, grid

    @anchor_x = nil
    @anchor_y = nil
    @current_x = nil
    @current_y = nil

    @found_lines = []
    @new_line_found = false

    @candidate_word = nil

    @border_color  = nil
    @margin = DEFAULT_MARGIN
    
    @center_x = @margin
    @center_y = @margin
    
    panel.preferred_size = Dimension.new(@margin * 2 + grid.cols * WIDTH, @margin * 2 + grid.rows * HEIGHT)

    setup_word_list
    
    set_painter
    set_mouse_handlers
    
  end

  def setup_word_list
    
    @words_list = []
    
    @grid.each_word do |word|
      @words_list << word
    end

    @full_list = Array.new(@words_list)
    
  end
  
  def restart grid = nil

    if grid
      
      @grid = grid
      @new_grid = true
      
      setup_word_list
      
    end
    
    @words_list = Array.new(@full_list)
    
    @found_lines.clear
    @new_line_found = true
    
    @panel.repaint
    
  end
  
  def show_words
    
    @words_list.each do |word|
      
      x1, y1 = cell_to_pixel(*word.slot.first)
      x2, y2 = cell_to_pixel(*word.slot.last)
      
      @found_lines << [x1, y1, x2, y2]
      
    end
    
    @new_line_found = true
      
    @panel.repaint
    
  end
  
  def hint_for word
      
    @hint = word
    @hint_index = word.reverse? ? word.slot.length - 1 : 0
    
    if @timer
      
      @timer.restart
      
    else
      
      l = ActionListener.new
    
      l.register do
        
        if @hint
          
          if @hint_index >= @hint.slot.length or @hint_index < 0
            @keep_hint = @hint
            @keep_count = 5
            @hint = nil
          end
          
          @panel.repaint
          
        elsif @keep_hint
          @panel.repaint
        end
        
      end
      
      @timer = Timer.new(200, l)
    
      @timer.start
      
    end
    
  end
  
  def set_painter
    
    @panel.on_styles do |styles|
      
      @back_color = styles.resolver.find_background_color(:table, @style_id)
      @back_color = styles.resolver.find_background_color(:container, @style_id) unless @back_color
      
      border_color = styles.resolver.find(:border_color, :table_row, @style_id)
      border_color = styles.resolver.find(:border_color, :table, @style_id) unless border_color
      @border_color = styles.resolver.create_color(border_color) if border_color
      
      margin = styles.resolver.find(:margin, :table, @style_id)
      
      if margin
        @margin = margin
        @panel.preferred_size = Dimension.new(@margin * 2 + @grid.cols * WIDTH, @margin * 2 + @grid.rows * HEIGHT)
      end
      
    end
    
    @panel.on_paint do |g|
     
      g.layer(:background, @new_grid) do |bg|

        @center_x = (g.width - @panel.preferred_size.width) / 2 + @margin
        @center_y = (g.height - @panel.preferred_size.height) / 2 + @margin
        
        bg.background @back_color
        bg.clear
        
        bg.antialias = true
        bg.set_font "Verdana", Font::ITALIC, 14

        bg.color @border_color if @border_color
        
        @grid.each_line do |line|
          
          line.each do |row, col|
       
            char = @grid[row, col]
            
            bg.move_to @center_x + col * WIDTH, @center_y + row * HEIGHT
            bg.box WIDTH, HEIGHT, char
            
          end
          
          @new_grid = false
          
        end
        
      end
     
      g.layer(:found, @new_line_found) do |found_g|
     
        @found_lines.each do |line|
          found_g.up
          found_g.move_to line[0], line[1]
          found_g.down
          found_g.move_to line[2], line[3]
        end
       
        @new_line_found = false
     
      end
      
      if @anchor_x
        g.up
        g.move_to @anchor_x, @anchor_y
        g.down
        g.move_to @current_x, @current_y
      end
      
      if @hint and @hint.slot[@hint_index]
        
        if @hint.reverse?
          start = @hint.slot.length - 1
        else
          start = 0
        end
                
        draw_hint_line g, @hint, start, @hint_index
          
        if @hint.reverse?
          @hint_index -= 1
        else
          @hint_index += 1
        end
        
      elsif @keep_hint
        
        @keep_count -= 1
        
        if @keep_count <= 0
          @keep_hint = nil
          @timer.stop
        else
          
          if @keep_hint.reverse?
            start = @keep_hint.slot.length - 1
            last = 0
          else
            start = 0
            last = @keep_hint.slot.length - 1
          end

          draw_hint_line g, @keep_hint, start, last
          
        end
        
      end

      
    end

  end
  
  def set_mouse_handlers

    @panel.on_mouse_move do |x, y|

      unless @anchor_x
      
        @anchor_x = x
        @anchor_y = y
        
        row, col = pixel_to_cell(x, y)
        
        @candidate_word = find_word(row, col)
        
      end
     
      @current_x = x
      @current_y = y
     
      @panel.repaint
     
    end

    @panel.on_mouse_up do |x, y|
     
      if @anchor_x and @candidate_word
        
        row, col = pixel_to_cell(x, y)
        
        r1, c1 = @candidate_word.slot[0]
        r2, c2 = @candidate_word.slot.last
        
        if (row == r1 and col == c1) or (row == r2 and col == c2)
            
            start_row, start_col = pixel_to_cell(@anchor_x, @anchor_y)
            
            unless start_row == row and start_col == col
        
              x1, y1 = cell_to_pixel(r1, c1)
              x2, y2 = cell_to_pixel(r2, c2)
              
              @found_lines << [x1, y1, x2, y2]
              @new_line_found = true
              
              consume @candidate_word
              
              @listener.call(@candidate_word)
              
            end
          
        end
        
      end
     
      @candidate_word = nil
     
      @anchor_x = nil
      @anchor_y = nil
     
      @panel.repaint
     
   end
   
  end
  
  def pixel_to_cell x, y
      
    col = ((x - @center_x) / WIDTH).to_i
    row = ((y - @center_y) / HEIGHT).to_i
    
    return row, col
    
  end
    
  def cell_to_pixel row, col
    return col * WIDTH + @center_x + WIDTH / 2, row * HEIGHT + @center_y + HEIGHT / 2    
  end

  def draw_hint_line g, word, first, last
                  
    x1, y1 = cell_to_pixel(*word.slot[first])
    x2, y2 = cell_to_pixel(*word.slot[last])
    
    g.color AWT::Color::RED
    
    g.up
    g.move_to x1, y1
    g.down
    g.move_to x2, y2
    
end
  
  def find_word(row, col)

    @words_list.each do |word|
      
      r1, c1 = *word.slot[0]
      r2, c2 = *word.slot.last
      
      return word if (row == r1 and col == c1) or (row == r2 and col == c2)
      
    end
    
    nil
    
  end

  def consume word
    @words_list.delete(word)
  end

end

module Swiby

  module Builder
  
    def puzzle_board grid, name, &listener
      
      panel = draw_panel
      
      board = PuzzleBoard.new(panel, grid, &listener)
      
      context[name] = board
      
      board
      
    end
    
  end
  
end
