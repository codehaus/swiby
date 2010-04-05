#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class SquarePainter < ClockPainter

  def initialize
    super
    @green = Color.new(123, 232, 76)
    @font = Graphics.create_font('arial', 0, 12)
    @big_font = Graphics.create_font('arial', 0, 75)
  end
  
  def clock bg
    
    bg.background Color::BLACK
    bg.clear
    
    w = bg.drawing_width
    h = bg.drawing_height
    
    bg.gradient 0.0, 0.0, Color.new(149, 174, 21, 0), w, h, Color.new(98, 121, 7, 255)
    bg.fill_rect 0, 0, w, h

  end
  
  def second_hand g, seconds

    g.color @green
    g.set_font @font
    
    rect = g.string_bounds('60')
    
    x = (g.drawing_width - rect.width * 16) / 2
    y = (g.drawing_height - 12 * 16) / 2
    
    seconds = seconds.to_i
    
    if seconds < 15
      x = x + seconds.modulo(15) * rect.width
    elsif seconds < 30
      x = x + 15 * rect.width
      y = y + seconds.modulo(15) * rect.height
    elsif seconds < 45
      x = x + 15 * rect.width - seconds.modulo(15) * rect.width
      y = y + 15 * rect.height
    else
      y = y + 15 * rect.height - seconds.modulo(15) * rect.height
    end
    
    g.draw_string "#{seconds.to_i}", x, y
    
    text = "%02d#{seconds.modulo(2).zero? ? ':' : ' '}%02d" % [@hour, @minutes]
    g.set_font @big_font
    g.centered_string text, @centerx, @centery
    
  end
  
  def minute_hand g, minutes
    @minutes = minutes.to_i
  end
  
  def hour_hand g, hour
    @hour = hour.to_i
  end

end
