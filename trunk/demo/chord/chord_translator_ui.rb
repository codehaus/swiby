#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc/frame'
require 'swiby/mvc/text'
require 'swiby/mvc/draw_panel'

require 'swiby/layout/form'

require 'swiby/swing/timer'

require 'chord_translator'
require 'score_painter'

panel = frame(:layout => :form, :vgap => 10, :hagp => 10) {

  title "Chord translator"
  
  use_styles 'styles.rb'
  
  width 700
  height 320

  input "Chord  ", "",  :name => :symbol
  
  @painter = ScorePainter.new
  
  draw_panel(:name => :score, :width => 600, :height => 300) { |g|
  
    g.layer(:background) { |bg|
      @painter.paint_background bg
    }
    
    g.layer(:notes) { |g_notes|
      @painter.paint_chord g_notes, @current_chord if @current_chord
    }
        
  }
    
  visible true
  
  every 1000 do
    
    value = @symbol.value.strip
    
    if value != @chord_symbol
      
      @chord_symbol = value
      
      begin
        chord = Chord.new(@chord_symbol)
      rescue
        @current_chord = nil
        bg_color = value.length == 0 ? Color::WHITE : Color::RED
      else
        @current_chord = chord.to_a
        bg_color = Color::WHITE
      end
    
      @styles.change!(:background_color) do |path, color|
        path == 'root' ? bg_color : color
      end
      
      @symbol.apply_styles @styles
      @score.layer(:notes).repaint
        
    end
    
  end
  
}

ViewDefinition.bind_controller panel
