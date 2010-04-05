#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/2d'

class Sequencer
  
  include Enumerable
  
  attr_reader :frames, :index
  
  def initialize
  
    @fps = 25
    @index = 0
    @looping = false
    @playing = false
    
    @frames = []
    
  end

  def painter
    
    proc do |g|
      @frames[@index].paint g
    end
    
  end
  
  def position_listener= listener
    @position_listener = listener
  end
  
  def image_frames width, height
    
    array = []
    
    @frames.each_index do |index|
      array << ImagePainter.new(@frames[index], width, height)
    end
    
    array
    
  end
  
  def size
    @frames.size
  end
  
  def each
    @frames.each do |frame|
      yield(frame)
    end
  end
  
  def delete_at index
    
    stop
    
    @frames.delete_at index
    
  end
  
  def goto index
    
    @index = index unless index >= @frames.length
    
  end
  
  def backward
    
    i = @index
    
    @index -=1
    @index = 0 if @index < 0
      
    @position_listener.position = @index unless @position_listener.nil? or @index == i
    
  end
  
  def forward
    
    i = @index
    
    @index +=1
    
    if @index >= @frames.length
      @index = 0 if @looping
      @index -=1 unless @looping
    end
    
    @position_listener.position = @index unless @position_listener.nil? or @index == i
    
  end
  
  def playing?
    @playing
  end
  
  def start
  
    freq = 1000 / @fps
    
    unless @timer

      @timer = every freq do
        forward if @playing
      end
    
      @timer.coalesce = false
      
    end
    
    @playing = true
  
  end
    
  def pause
    @playing = false
  end
    
  def stop
    
    if @timer
      @timer.stop
      @timer = nil
    end
  
    @index = 0
    @playing = false
    
    @position_listener.position = @index unless @position_listener.nil?
    
  end
  
  def loop enabled = true
    @looping = enabled
  end
  
  def to_s
    
    detail = ''
    count = 0
    mood = nil
    
    @frames.each do |frame|
      
      if mood and frame.mood != mood
        detail += "\n    #{count} frames as '#{mood}'"
        count = 0
      end
      
      count += 1
      mood = frame.mood
      
    end

    detail += "\n    #{count} frames as '#{mood}'"
        
    "Sequence contains #{@frames.size} frames: #{detail}"
    
  end
  
end

def smiley &scenario
  
  sequencer = Sequencer.new
  
  bound_self = eval('self', scenario.binding)
  
  bound_self.class.send(:include, Smiley)
  bound_self.instance_variable_set(:@frames, sequencer.frames)

  scenario.call
  
  sequencer
  
end

module Smiley
    
  SMILE_PAINTERS = {
    :happy => proc { |smiley_g|
      smiley_g.draw_arc 45, 77, 30, 20, 210, 120
    },
    :sad => proc {|smiley_g|
      smiley_g.draw_arc 45, 97, 30, 20, 30, 120
    }
  }
  
  EYES_PAINTERS = {
    :left_open => proc { |eye_g|
      draw_oval eye_g, 80, 40, 20, 20, 2, Color::RED
    },
    :right_open => proc { |eye_g|
      draw_oval eye_g, 20, 40, 20, 20, 2, Color::RED
    }
  }

  MOOD_CHANGE_GENERATORS = {:happy => :generate_get_happy, :sad => :generate_get_sad}
  
  def happy
    :happy
  end

  def is *args
    
    mood = args[0]
    smile = SMILE_PAINTERS[mood]

    raise "Unknown mood '#{mood}'" unless smile
    
    painter = SmileyPainter.new(mood)
    painter.smile_painter = smile
    
    painter.left_eye = EYES_PAINTERS[:left_open]
    painter.right_eye = EYES_PAINTERS[:right_open]
    
    20.times do
      @frames << painter
    end
    
  end

  def left_eye
    :left_eye
  end

  def right_eye
    :right_eye
  end

  def winks *args
    
    mood = @frames.last.mood
    mood = :happy if @frames.size == 0
    
    eye = args[0]
    
    smile = SMILE_PAINTERS[mood]
    
    15.times do |i|
      
      painter = SmileyPainter.new(mood)
      painter.smile_painter = smile
      
      painter.left_eye = EYES_PAINTERS[:left_open] unless eye == :left_eye
      painter.right_eye = EYES_PAINTERS[:right_open] unless eye == :right_eye
      
      if eye == :left_eye
        
        painter.left_eye = proc { |eye_g|

          draw_oval eye_g, 80, 40 + (i/2), 20, 20 - i, 2, Color::RED
          
        }
        
      end
      
      if eye == :right_eye
        
        painter.right_eye = proc { |eye_g|

          draw_oval eye_g, 20, 40 + (i/2), 20, 20 - i, 2, Color::RED
                 
        }
        
      end
      
      @frames << painter
      
    end
    
    15.downto(1) do |i|
      
      painter = SmileyPainter.new(mood)
      painter.smile_painter = smile
      
      painter.left_eye = EYES_PAINTERS[:left_open] unless eye == :left_eye
      painter.right_eye = EYES_PAINTERS[:right_open] unless eye == :right_eye
      
      if eye == :left_eye
        
        painter.left_eye = proc { |eye_g|

          draw_oval eye_g, 80, 40 + (i/2), 20, 20 - i, 2, Color::RED
          
        }
        
      end
      
      if eye == :right_eye
        
        painter.right_eye = proc { |eye_g|

          draw_oval eye_g, 20, 40 + (i/2), 20, 20 - i, 2, Color::RED
                 
        }
        
      end
      
      @frames << painter
      
    end
    
  end
    
  def sad
    :sad
  end
    
  def gets *args
    
    raise "No previous mood" if @frames.size == 0
    
    mood = @frames.last.mood
    
    return if @frames.last.mood == args[0]
    
    mood = args[0]
    
    mood_change = MOOD_CHANGE_GENERATORS[mood]
    
    raise "Don't know how to change mood, unknown mood '#{mood}'" unless mood_change
    
    self.send mood_change
    
  end

  private
    
    def draw_oval g, x, y, w, h, border, border_color
      g.stroke_width border
      g.color border_color
      g.draw_oval x, y, w, h
      g.color Color::BLACK
      g.fill_oval x, y, w, h
    end

    def generate_get_sad
      @frames.concat generate_getting_sad_frames_as(:sad)
    end
    
    def generate_get_happy
      @frames.concat generate_getting_sad_frames_as(:happy).reverse!
    end
    
    def generate_getting_sad_frames_as mood
      
      getting_sad = []
      
      20.times do |i|
        
        smile =  proc do |smiley_g|
          smiley_g.draw_arc 45, 77 + i, 30, 20 - i, 210, 120
        end
        
        painter = SmileyPainter.new(mood)
        painter.smile_painter = smile
    
        painter.left_eye = EYES_PAINTERS[:left_open]
        painter.right_eye = EYES_PAINTERS[:right_open]
        
        getting_sad << painter
        
      end

      20.downto(0) do |i|
        
        smile = proc do |smiley_g|
          smiley_g.draw_arc 45, 97, 30, 20 - i, 30, 120
        end
        
        painter = SmileyPainter.new(mood)
        painter.smile_painter = smile
    
        painter.left_eye = EYES_PAINTERS[:left_open]
        painter.right_eye = EYES_PAINTERS[:right_open]
        
        getting_sad << painter
        
      end
      
      getting_sad

    end

  class SmileyPainter
    
    attr_reader :mood
    attr_writer :smile_painter
    attr_writer :left_eye, :right_eye
    
    def initialize mood    
      @mood  = mood
      @refresh = false
    end
    
    def paint g
    
      g.layer(:background) do |bg|
      
        bg.antialias = true
      
        bg.background Color::BLACK
        bg.clear
      
      end
      
      g.layer(:smiley) do |smiley_g|
      
        unless g.width == 120 and g.height == 120
          
          scale_x = g.width / 120.0
          scale_y = g.height / 120.0
      
          smiley_g.scale scale_x, scale_y
          
        end
      
        smiley_g.antialias = true
      
        draw_oval smiley_g, 1, 1, 116, 116, 2, Color::RED

        smiley_g.color Color::RED
      
        nose = smiley_g.polygon [60, 60], [70, 70], [50, 70]
        smiley_g.fill_polygon nose
      
        @left_eye.call smiley_g
        @right_eye.call smiley_g
        
        smiley_g.color Color::RED
        
        @smile_painter.call smiley_g
      
        smiley_g.scale 0, 0
        
      end
      
    end

  end
  
end
