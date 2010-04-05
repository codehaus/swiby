#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class BasicPainter < ClockPainter

  def clock bg
    
    bg.background Color::BLACK

    bg.clear

    bg.color Color::WHITE
    bg.stroke_width 8
    bg.fill_oval @centerx - 102, @centery - 102, 204, 204
    
    bg.translate @centerx, @centery

    bg.color Color::BLACK
    bg.stroke_width 3

    bg.stroke_width 1
    
    @font = Graphics.create_font('arial', 0, 16) unless @font
   
    bg.set_font @font

    if Time.new.hour < 12
      pos = [
        [@centerx - 124, @centery - 200],
        [@centerx - 35, @centery - 115],
        [@centerx - 124, @centery - 27],
        [@centerx - 212, @centery - 115]
      ]
      texts = ['0', '3', '6', '9']
    else
      pos = [
        [@centerx - 129, @centery - 200],
        [@centerx - 45, @centery - 115],
        [@centerx - 129, @centery - 27],
        [@centerx - 210, @centery - 115]
      ]
      texts = ['24', '15', '18', '21']
    end
    4.times do |i|
      bg.draw_string texts[i],  pos[i][0], pos[i][1]
    end
    
  end
  
  def draw_second_hand g
    g.color Color::RED
    g.stroke_width 2
    g.draw_line 0, 0, @radius - 15, 0
    g.fill_oval -4, -4, 8, 8
  end
  def draw_minute_hand g
    g.color Color::BLACK
    g.stroke_width 2
    g.draw_line 0, 0, @radius, 0
  end
  def draw_hour_hand g
    g.color Color::BLACK
    g.draw_line 0, 0, @radius - 20, 0
  end

end
