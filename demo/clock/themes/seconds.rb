#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class SecondsPainter < ClockPainter

  ONE_SECOND_ANGLE =  360 / 60
  
  def clock bg
    
    bg.background Color::BLACK
    bg.clear
    
  end
  
  def second_hand g, seconds
    
    @font = Graphics.create_font('courier', Font::BOLD, 16) unless @font
    
    w = 240 - 60
    h = 240 - 60
    x = (240 - w) / 2
    y = (240 - h) / 2
    
    g.set_font @font

    seconds.times do |i|
      
      angle = 90 - ONE_SECOND_ANGLE - i * ONE_SECOND_ANGLE
      
      g.color Color.new(255, 255, 120 - i * 2)
    
      g.fill_arc x, y, w, h, angle, ONE_SECOND_ANGLE + 1
      
    end
  
    g.color Color::WHITE

    x =  @centerx + (Math.cos((@minutes * Math::PI / 30) - Math::PI / 2) * 105).to_i
    y =  @centery + (Math.sin((@minutes * Math::PI / 30) - Math::PI / 2) * 105).to_i
    text = "#{@minutes.to_i}"
    rect = g.string_bounds(text)
    x -= rect.width / 2
    y += rect.height / 2
    g.draw_string text, x, y
    
    g.color Color::GRAY
    
    x =  @centerx + (Math.cos((@hour * Math::PI / 6) - Math::PI / 2) * 70).to_i
    y =  @centery + (Math.sin((@hour * Math::PI / 6) - Math::PI / 2) * 70).to_i
    text = "#{@hour.to_i}"
    rect = g.string_bounds(text)
    x -= rect.width / 2
    y += rect.height / 2
    g.draw_string text, x, y

  end
  
  def minute_hand g, minutes
    @minutes = minutes.to_i
  end
  
  def hour_hand g, hour    
    @hour = hour
  end

end
