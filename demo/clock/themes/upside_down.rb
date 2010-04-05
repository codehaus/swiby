#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class UpsideDownPainter < ClockPainter

  def clock bg
    
    bg.background Color::BLACK
    bg.clear

  end
  
  def second_hand g, seconds

    w = 200
    h = 200
    x = (240 - w) / 2
    y = (240 - h) / 2
    
    g.color Color::YELLOW

    g.stroke_width 3
    
    g.draw_line x + w / 2, y, x + w / 2, y + 2
    g.draw_line x + w / 2, y + h, x + w / 2, y + h - 2

    g.draw_line x, y + h / 2, x + 2, y + h / 2
    g.draw_line x + w, y + h / 2, x + w - 2, y + h / 2
  
    g.translate @centerx, @centery
    g.rotate((seconds * Math::PI / 30) - Math::PI / 2)
    g.scale 1.7

    g.stroke_width 1
    g.draw_line 10, 0, 30, 0
    
    g.color Color::RED
    
    g.draw_string "#{@hour.to_i}", 10, -2
    g.draw_string "#{@minutes.to_i}", 30, 10
    
  end
  
  def minute_hand g, minutes
    @minutes = minutes
  end
  
  def hour_hand g, hour
    @hour = hour
  end

end
