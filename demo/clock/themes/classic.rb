#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class ClassicPainter < ClockPainter

  def clock bg
    
    bg.background Color::BLACK
    bg.clear

    bg.color Color::WHITE
    bg.fill_oval @centerx - 102, @centery - 102, 204, 204
    bg.stroke_width 8
    bg.color Color.new(211, 207, 56)
    bg.draw_oval @centerx - 102, @centery - 102, 204, 204
    
    bg.translate @centerx, @centery

    bg.color Color::BLACK
    bg.stroke_width 3

    4.times do
      bg.rotate Math::PI / 2
      bg.draw_line 0, @radius + 7, 0, @radius - 4
    end

    bg.stroke_width 1

    12.times do
      bg.rotate Math::PI / 6
      bg.draw_line 0, @radius + 7, 0, @radius
    end
    
    60.times do
      bg.rotate Math::PI / 30
      bg.draw_line 0, @radius + 5, 0, @radius + 5
    end
    
   @font = Graphics.create_font('arial', 0, 16) unless @font

    bg.set_font @font

    if Time.new.hour < 12
        bg.draw_string '8', @centerx - 192, @centery - 71
    else
        bg.draw_string '20', @centerx - 192, @centery - 71
    end
    
  end
  
  def draw_second_hand g
    g.color Color::RED
    g.stroke_width 2
    g.draw_line -15, 0, @radius, 0
    g.fill_oval -3, -3, 6, 6
  end
  def draw_minute_hand g
    g.color Color::BLACK
    p = g.polygon [0, -9], [90, 0], [0, 9]
    g.fill_polygon p
    g.fill_oval -10, -10, 20, 20
  end
  def draw_hour_hand g
    g.color Color::DARK_GRAY.darker
    p = g.polygon [0, -9], [70, 0], [0, 9]
    g.fill_polygon p
    g.fill_oval -10, -10, 20, 20
  end

  def date g, time
    g.color Color::BLACK
    text = "#{time.strftime('%a')}"
    g.draw_string text, @centerx - 12, @centery + 33

    g.color Color::BLACK
    text = "#{time.strftime('%b %d')}"
    g.draw_string text, @centerx - 19, @centery + 49
  end

end