#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class WorldPainter < ClockPainter
  
  OFFSETS = [0, -8, -5, 0, 1, 4, 9, 10, 12]
  TOWNS = ['Local', 'Los Angeles', 'New York', 'London', 'Paris', 'Dubai', 'Tokyo', 'Sydney', 'Auckland']

  def clock bg
    
    bg.background Color::BLACK
    bg.clear

    @font = Graphics.create_font('courier', Font::BOLD, 12) unless @font
    @font_towns = Graphics.create_font('arial', Font::PLAIN, 10) unless @font_towns
    
    bg.set_font @font
    
    loop_9_clocks bg, :draw_clock
    
  end
  
  def draw_clock bg, index
    
    color = Color::BLUE.darker.darker unless index == 0
    color = Color::RED.darker.darker if index == 0
            
    bg.color Color::LIGHT_GRAY

    bg.fill_oval 8, 3, 64, 64
    
    bg.color color
    
    bg.gradient 10, 5, Color::WHITE, 10, 13, color, false
    bg.fill_oval 10, 5, 60, 60
    
    bg.color Color::WHITE
    bg.centered_string '12', 40, 10
    bg.centered_string  '9', 18, 32
    bg.centered_string  '3', 60, 32
    bg.centered_string  '6', 40, 55
    
  end

  def second_hand g, seconds, *args
    
    if args.length > 0
      
      seconds = args.first
      
      g.color Color::YELLOW
      
      x = 40 + (Math.cos((seconds * Math::PI / 30) - Math::PI / 2) * 24).to_i
      y = 34 + (Math.sin((seconds * Math::PI / 30) - Math::PI / 2) * 24).to_i
      
      g.stroke_width 1
      g.draw_line x, y, 40, 34
      
    else
      loop_9_clocks g, :second_hand, seconds.to_i
    end
  
  end
  def minute_hand g, minutes, *args
    
    if args.length > 0
    
      minutes = args.first
      
      g.color Color::WHITE
      
      x =  40 + (Math.cos((minutes * Math::PI / 30) - Math::PI / 2) * 20).to_i
      y =  34 + (Math.sin((minutes * Math::PI / 30) - Math::PI / 2) * 20).to_i
      
      g.stroke_width 3, BasicStroke::CAP_ROUND, BasicStroke::JOIN_ROUND
      g.draw_line x, y, 40, 34
      
    else
      loop_9_clocks g, :minute_hand, minutes.to_i
    end
    
  end
  def hour_hand g, hour, *args
    
    if args.length > 0
    
      index = hour
      hour = (Time.now.gmtime + (OFFSETS[index] * 60 * 60)).hour if index > 0
      hour = args.first if index == 0
      
      g.color Color::WHITE
      
      x =  40 + (Math.cos((hour * Math::PI / 6) - Math::PI / 2) * 14).to_i
      y =  34 + (Math.sin((hour * Math::PI / 6) - Math::PI / 2) * 14).to_i
      
      g.stroke_width 3, BasicStroke::CAP_ROUND, BasicStroke::JOIN_ROUND
      g.draw_line x, y, 40, 34
      
      g.color Color::YELLOW
      g.set_font @font_towns
      g.centered_string TOWNS[index], 40, 73
      
    else
      loop_9_clocks g, :hour_hand, hour.to_i
    end
    
  end

  def loop_9_clocks g, drawer, *args
        
    y = 0
    index = 0
    
    3.times do
      
      x = 0
      
      3.times do
        
        g.translate x, y
        
        send drawer, g, index, *args
        
        g.translate -x, -y
        
        index += 1
        x += 80
        
      end
      
      y += 80
      
    end
    
  end
  
end
