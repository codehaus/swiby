#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class FallingPainter < ClockPainter

  def initialize
    @font = Graphics.create_font('arial', 0, 20)
  end
  
  def clock bg
    
    bg.background Color::BLACK
    bg.clear
    
    @number_rect = bg.string_bounds('00000')
    
    @x1 = 20
    @x2 = @x1 + @number_rect.width
    @x3 = @x2 + @number_rect.width
    
  end
  
  def date g, time

    text = "#{time.strftime('%d/%m/%Y')}"
    
    g.set_font @font

    rect = g.string_bounds(text)
    
    x = g.drawing_width - rect.width - 5
    y = g.drawing_height - rect.height
    
    g.gradient x, y, Color.new(0, 0, 195, 100), x, y + rect.height, Color.new(0, 0, 195, 255)
    
    g.draw_string text, x, g.drawing_height - rect.height
    
  end
  
  def second_hand g, seconds
    draw_value g, seconds.to_i, @x3, 10
  end
  
  def minute_hand g, minutes
    draw_value g, minutes.to_i, @x2, 10
  end
  
  def hour_hand g, hour
    draw_value g, hour.to_i, @x1, 6
  end
  
  def draw_value g, value, x, modulo

    g.set_font @font
    
    text = "#{value}"
    
    rect = g.string_bounds(text)
    
    height = g.drawing_height - modulo * @number_rect.height
    
    x = x
    y = height / 2 + value.modulo(modulo) * @number_rect.height
    
    white_gradient g, x, y, rect.width, @number_rect.height
    
    g.draw_string text, x, y
    
  end
  
  def white_gradient g, x, y, w, h
    g.gradient x, y, Color.new(255, 255, 255, 100), x + w / 2, y, Color.new(255, 255, 255, 255)
  end
      
end
