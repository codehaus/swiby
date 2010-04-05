#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc/draw_panel'

module Swiby

  module Builder
    
    def hangman_board name, width, height
      
      panel = draw_panel(:name => name, :width => width, :height => height) do |g|
      
        g.layer(:background) { |bg|
          
          bg.gradient 0, 0, Color.new(122, 81, 159, 155), 0, height, Color::WHITE
          bg.fill_rect 0, 0, width, height
          
          bg.antialias = true
          
          p = bg.polygon([25, 80], [92, 24], [100, 33], [33, 90])
          
          bg.color Color.new(92, 51, 23)
          bg.fill_rect 20, 20, 30, 300
          bg.color Color.new(139, 69, 19)
          bg.fill_rect 20, 20, 170, 20
          
          bg.color Color.new(205, 102, 29)
          bg.fill_polygon p

          # some nails...
          bg.color Color::BLACK
          bg.fill_oval 24, 24, 4, 4
          bg.fill_oval 24, 32, 4, 4
          bg.fill_oval 34, 26, 4, 4
          bg.fill_oval 39, 32, 4, 4
          
          bg.fill_oval 32, 80, 4, 4
          bg.fill_oval 41, 72, 4, 4
          
          bg.fill_oval 90, 30, 4, 4
          
          # the rope
          bg.color Color::WHITE
          bg.fill_rect 160, 40, 5, 60
          
        }
        
        g.layer(:man) { |gr|

          gr.antialias = true

          if panel.errors_count > 0
            # head
            gr.stroke_width 3
            gr.color Color::BLACK
            gr.draw_oval 152, 101, 20, 20
            gr.color Color::WHITE        
            gr.fill_oval 152, 101, 20, 20
          end
          
          if panel.errors_count > 1
            # body
            gr.stroke_width 5
            gr.color Color::BLACK
            gr.draw_line 163, 122, 163, 180
          end
        
          if panel.errors_count > 2
            # right arm
            gr.stroke_width 5
            gr.color Color::BLACK
            gr.draw_line 161, 128, 148, 165
          end
        
          if panel.errors_count > 3        
            # left arm
            gr.stroke_width 5
            gr.color Color::BLACK
            gr.draw_line 165, 128, 177, 165
          end
        
          if panel.errors_count > 4
            # right leg
            gr.stroke_width 5
            gr.color Color::BLACK
            gr.draw_line 162, 177, 150, 240
          end
        
          if panel.errors_count > 5
            # left leg
            gr.stroke_width 5
            gr.color Color::BLACK
            gr.draw_line 164, 177, 177, 240
          end
        
          if panel.errors_count > 6
            # right shoe
            gr.stroke_width 4
            gr.color Color::RED
            gr.draw_line 151, 240, 140, 239
          end
        
          if panel.errors_count > 7
            # left shoe
            gr.stroke_width 4
            gr.color Color::RED
            gr.draw_line 176, 240, 187, 239
          end
        
        }
      
      end

      def panel.errors_count
        @errors_count
      end
      
      def panel.errors_count= n
        @errors_count = n
        layer(:man).repaint
      end
      
      panel.instance_variable_set :@errors_count, 0
      
      panel
      
    end
    
  end
  
end
