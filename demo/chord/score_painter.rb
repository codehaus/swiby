#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/2d'

class ScorePainter
  
  LINE_5 = 70
  
  NOTES_Y = [
     LINE_5 + 3 * 30 - 27, # A
     LINE_5 + 2 * 30 - 12, # B
     LINE_5 + 5 * 30 - 12, # C
     LINE_5 + 4 * 30 + 3,  # D
     LINE_5 + 4 * 30 - 12, # E
     LINE_5 + 3 * 30 + 3,  # F
     LINE_5 + 3 * 30 - 12, # G
  ]
  UPPER_NOTES_Y = [
     LINE_5 - 1 * 30 - 12, # A
     LINE_5 + 2 * 30 - 12, # B
     LINE_5 + 1 * 30 + 3,  # C
     LINE_5 + 1 * 30 - 12, # D
     LINE_5 + 0 * 30 + 3 , # E
     LINE_5 + 0 * 30 - 12, # F
     LINE_5 - 1 * 30 + 3,  # G
  ]
  
  FLAT_CODE = 67
  SHARP_CODE = 6
  G_CLEF_CODE = 9

  def initialize
    @musical_font = Graphics.create_font("MusicalSymbols", Font::PLAIN, 120)
    @musical_font_small = Graphics.create_font("MusicalSymbols", Font::PLAIN, 80)
  end
  
  def paint_background bg
    
    bg.background Color::WHITE
    bg.clear
  
    bg.antialias = true
    
    bg.stroke_width 1
    bg.color Color::GRAY
    bg.draw_rect 0, 0, bg.width, bg.height
    
    # draw staff
    bg.stroke_width 2
    bg.color Color::BLACK
    
    5.times do |i|
      
      pos = LINE_5 + i * 30
    
      bg.draw_line 10, pos, bg.width - 10, pos
      
    end
    
    # draw treble clef
    bg.set_font @musical_font
    bg.draw_glyph G_CLEF_CODE, 10, NOTES_Y[3]
    
  end
  
  def paint_chord g, chord
    
    g.antialias = true
    g.color Color::BLUE
    
    x = 160
    previous_y = 300    
    
    chord.each do |note|
      
      i = note.index
      
      lower, y = true, NOTES_Y[i]
      lower, y = false, UPPER_NOTES_Y[i] if y > previous_y
    
      g.fill_oval x, y, 40, 24
      
      if (lower and 'C' == note.note) or (!lower and 'A' == note.note) 
        g.stroke_width 2
        g.draw_line x - 11, y + 10, x + 40 + 10, y + 11
      end
      
      if note.pitch == '#'
        draw_sharp g, x, y
      elsif note.pitch == 'b'
        draw_flat g, x, y
      end
      
      previous_y = y
      x += 100
      
    end
    
  end
    
  def draw_sharp g, x, y
    
    x -= 20
    y += 13
    
    g.set_font @musical_font_small
    g.draw_glyph SHARP_CODE, x, y
    
  end
  
  def draw_flat g, x, y
    
    x -= 20
    y += 13
    
    g.set_font @musical_font_small
    g.draw_glyph FLAT_CODE, x, y
    
  end
  
end