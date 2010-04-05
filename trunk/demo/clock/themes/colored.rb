#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class ColoredPainter < ClockPainter

  COLORS = [
    Color.new(185, 0, 0), Color::BLACK, Color.new(128, 255, 0), 
    Color::BLUE, Color.new(176, 0, 176), Color::YELLOW, 
    Color::PINK, Color::GRAY, Color.new(175, 7, 10), 
    Color::WHITE, Color::CYAN, Color::ORANGE
  ]
  
  def clock bg
    
    bg.antialias = true
    
    bg.background Color.new(106, 106, 53)
    bg.clear

    bg.stroke_width 8
    bg.color Color.new(175, 175, 95)
    bg.draw_oval @centerx - 102, @centery - 102, 204, 204
    bg.fill_oval @centerx - 102, @centery - 102, 204, 204
    
    bg.translate @centerx, @centery

    @font = Graphics.create_font('arial', Font::PLAIN, 18) unless @font
    
    bg.set_font @font

    angle = -Math::PI / 2
    
    12.downto(1) do |i|
      
      bg.color COLORS[i - 1]
      
      x = Math::cos(angle) * @radius
      y = Math::sin(angle) * @radius
      
      bg.centered_string i.to_s, x, y
      
      angle -= Math::PI / 6
      
    end
    
    bg.stroke_width 1
    bg.color Color.new(128, 128, 64)

    60.times do
      bg.rotate Math::PI / 30
      bg.draw_line 0, @radius - 18, 0, @radius - 21
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
    g.stroke_width 2
    g.draw_line -10, 0, 80, 0
  end
  def draw_hour_hand g
    g.color Color.new(0, 128, 0)
    g.stroke_width 2
    g.draw_line -10, 0, 60, 0
  end

end