#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class ModernPainter < ClockPainter

  def clock bg
    
    bg.background Color::BLACK
    bg.clear

    bg.color Color::WHITE
    
    bg.translate @centerx, @centery

    bg.color Color::DARK_GRAY
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
    g.fill_oval @radius - 16, 3, 6, 6
  end
  def draw_minute_hand g
    g.color Color::DARK_GRAY
    p = g.polygon [0, -2], [90, 0], [0, 2]
    g.fill_polygon p
    g.fill_oval -4, -4, 8, 8
  end
  def draw_hour_hand g
    g.color Color::DARK_GRAY.darker
    p = g.polygon [0, -2], [70, 0], [0, 2]
    g.fill_polygon p
    g.fill_oval -4, -4, 8, 8
  end

  def date g, time
    g.color Color::RED.darker.darker

    text = "#{time.strftime('%a')}"
    g.draw_string text, @centerx - 13, @centery + 34

    text = "#{time.strftime('%b %d')}"
    g.draw_string text, @centerx - 20, @centery + 50
  end

end