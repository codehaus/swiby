#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class LinePainter < ClockPainter

  def clock bg
    
    bg.background Color.new(47, 47, 79)
    bg.clear
    
  end

  def second_hand g, seconds
    
    g.stroke_width 9, BasicStroke::CAP_ROUND, BasicStroke::JOIN_ROUND
    
    seconds = seconds.to_i
    
    g.color Color::WHITE
    
    x = seconds * 7
    x = 210 - (seconds - 30) * 7 if seconds > 30
    
    g.draw_line 15, 220, x + 15, 220
    
  end
  
  def minute_hand g, minutes
    
    g.stroke_width 9, BasicStroke::CAP_ROUND, BasicStroke::JOIN_ROUND
    
    x = 59 * 3
    x += 10
    
    g.color Color.new(122,139,139)
    g.draw_line 30, 10, x + 20, x
    
    minutes = minutes.to_i
    
    x = minutes * 3
    x += 10
    
    g.color Color.new(219, 219, 112)
    g.draw_line 30, 10, x + 20, x
    
  end
  
  def hour_hand g, hour
    
    g.stroke_width 9, BasicStroke::CAP_ROUND, BasicStroke::JOIN_ROUND
    
    x = 23 * 3
    x += 10
    
    g.color Color.new(122,139,139)
    g.draw_line 80, 10, x + 70, x
    
    x = hour.to_i * 3
    x += 10
    
    g.color Color.new(255,127,0)
    g.draw_line 80, 10, x + 70, x
    
  end

end
