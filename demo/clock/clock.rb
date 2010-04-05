#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby'
require 'swiby/mvc/image'
require 'swiby/mvc/frame'
require 'swiby/mvc/label'

require 'swiby/component/auto_hide'
require 'swiby/component/draw_panel'

require 'swiby/swing/timer'

class ClockPainter
  
  def initialize
    @radius, @centerx, @centery = 90, 120, 120
  end

  def self.load(dirname)
    
    Dir.open(dirname).each do |file|
      
      next unless file =~ /[.]rb$/
      
      require "#{dirname}/#{file}"
      
    end
      
  end
  
  def clock bg
  end
  
  def draw_second_hand g
  end
  def draw_minute_hand g
  end
  def draw_hour_hand g
  end

  def second_hand g, seconds
    g.translate @centerx, @centery
    g.rotate((seconds * Math::PI / 30) - Math::PI / 2)
    draw_second_hand g
  end
  def minute_hand g, minutes
    g.translate @centerx, @centery
    g.rotate((minutes * Math::PI / 30) - Math::PI / 2)
    
    draw_minute_hand g
    
    g.rotate(-(minutes * Math::PI / 30) + Math::PI / 2)
    g.translate -@centerx, -@centery
  end
  def hour_hand g, hour
    g.translate @centerx, @centery
    g.rotate((hour * Math::PI / 6) - Math::PI / 2)

    draw_hour_hand g
    
    g.rotate(-(hour * Math::PI / 6) + Math::PI / 2)
    g.translate -@centerx, -@centery
  end
  
  def date g, time
  end
  
  def name
    self.class.name.downcase =~ /(.*)painter/
    $1
  end
  
  @@painters = {}
  
  def self.each_painter
    @@painters.each {|name, painter| yield painter}
  end
  
  def self.create name
    @@painters[name.downcase]
  end
  
  def self.inherited painter
    
    name = painter.name.downcase
    
    if name =~ /(.*)painter/
      name = $1
    end
  
    @@painters[name] = painter
    
  end

end
  
class Clock
  
  attr_accessor :painter
  
  def initialize painter
    @time = Time.now
    @refresh = true
    @painter = painter
  end
  
  def refresh_background
    @refresh = true
  end

  def draw_clock g

    @time = Time.now
    
    g.drawing_size 240, 240
    
    g.layer(:background, @refresh) do |bg|
      bg.antialias = true
      @painter.clock bg
      @refresh = false
    end
    
    g.layer(:date, true) do |time_g|
      time_g.antialias = true
      @painter.date time_g, @time
    end
    
    g.layer(:time, true) do |time_g|
      time_g.antialias = true
      @painter.hour_hand time_g, @time.hour + (@time.min / 60.0)
      @painter.minute_hand time_g, @time.min + (@time.sec / 60.0)
      @painter.second_hand time_g, @time.sec
    end
    
  end

  def paint g
    draw_clock g
  end
  
end

ClockPainter.load(File.expand_path('themes', File.dirname(__FILE__)))

clock_themes = []
painter_name = nil

ClockPainter.each_painter do |painter_class|
  
  painter = painter_class.new
  painter_name = painter.name unless painter_name
  
  clock_themes << ImagePainter.new(Clock.new(painter), 100, 100)
  
end

painter_name = ARGV[0] if ARGV[0]

painter_class = ClockPainter.create(painter_name)
  
if painter_class
  
  f = frame {
    
    width 240
    height 240
    
    swing { |f| f.resizable = false}
    
    @clock = Clock.new(painter_class.new)
    
    title 'Clock'
    
    @display = draw_panel(:resize_always => true) { |g|
      @clock.draw_clock(g)
    }
    
    auto_hide('settings', :west, :bg_color => Color::GREEN) {
      image_list clock_themes, :item_layout => :vertical, :name => :themes
    }
    
    visible true

    every(1000) {
      @display.repaint      
    }
    
    def clock_painter= painter
      @clock.painter = painter
      @clock.refresh_background
      @display.repaint
    end
    
  }
  
  class ClockControler
    
    def themes= theme
      @window.clock_painter = theme.painter.painter.class.new
    end
    
  end
  
  ViewDefinition.bind_controller f, ClockControler.new
  
else
  $stderr.puts "Cannot find clock painter named '#{ARGV[0]}'"
end
