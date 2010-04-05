#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class BinaryPainter < ClockPainter

  def clock bg
    
    bg.background Color::BLACK
    bg.clear

    bg.stroke_width 4
    bg.color Color::GRAY
    bg.draw_round_rect 10, 10, 220, 220, 10, 10
    
    bg.color Color::DARK_GRAY.darker
    
    draw_leds bg,  30, 3
    draw_leds bg,  60, 15
    draw_leds bg, 100, 7
    draw_leds bg, 130, 15
    draw_leds bg, 170, 7
    draw_leds bg, 200, 15
    
  end

  def second_hand g, seconds
    draw_number g, 170, seconds.to_i
  end
  def minute_hand g, minutes
    draw_number g, 100, minutes.to_i
  end
  def hour_hand g, hour
    draw_number g, 30, hour.to_i
  end
  
  def draw_number g, x, number
    g.color Color::YELLOW
    draw_leds g, x, number / 10
    draw_leds g, x + 30, number % 10
  end
  
  def draw_leds g, x, digit
    
    y = 180
    
    while digit > 0
      
      g.fill_oval x, y, 10, 10 if odd?(digit)
      
      y -= 30
      digit >>= 1
      
    end

  end
  
  def odd? n
    n & 1 != 0
  end

end
