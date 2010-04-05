#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import java.awt.Color

class Turtle
  
  THEMES = {
    :red => [Color.new(72, 0, 0), Color::WHITE], 
    :bw => [Color::WHITE, Color::BLACK], 
    :blue => [Color.new(0, 0, 64), Color::WHITE],
    :yellow => [Color.new(255, 242, 0), Color.new(153, 0, 48)],
  }
  
  def initialize
    @theme = :red
  end
  
  def script= script
    
    begin
      @script = script
      @block = eval("proc {\n#{script}\n}")
    rescue Exception
    end
    
    @graphics[:surface].repaint if @graphics
    
  end
  
  def painter
    
    proc do |g|
      
      @graphics = g
      
      g.layer(:surface) do |gr|
        
        @procedures = {}
        @pending_procedure = nil
        
        @visible_turtle = true
        
        @layer_graphics = gr
        
        gr.antialias = true
        
        gr.color THEMES[@theme][1]
        gr.background THEMES[@theme][0]
        gr.clear
        
        self.angle = Math::PI / 2
        
        @pen = gr.create_pen(gr.width / 2, gr.height / 2)
        
        @pen.down

        begin
          instance_eval &@block
        rescue Exception
        end
        
        paint_turtle @pen.x, @pen.y, gr
        
      end
      
    end
    
  end
  
  SHORTCUTS = {:cs => :clearscreen, :st => :showturtle, :ht => :hideturtle, :fd => :forward, :bk => :back, :rt => :right, :lt => :left}
  
  def clearscreen
      
    @layer_graphics.clear
    
    self.angle = Math::PI / 2
    
    @pen = @layer_graphics.create_pen(@layer_graphics.width / 2, @layer_graphics.height / 2)
    
    @pen.down
      
  end
  
  def forward length
    @pen.move_to @pen.x + @cos * length, @pen.y - @sin * length
  end

  def back length
    @pen.move_to @pen.x - @cos * length, @pen.y + @sin * length
  end
  
  def right degrees
    self.angle = @turtle_angle - (degrees * Math::PI / 180)
  end

  def left degrees
    self.angle = @turtle_angle + (degrees * Math::PI / 180)
  end
  
  def up
    @pen.up
  end
  
  def down
    @pen.down
  end
  
  def showturtle
    @visible_turtle = true
  end
  
  def hideturtle
    @visible_turtle = false
  end
  
  def repeat n
    n.times {yield}
  end
  
  def angle= radians
    @turtle_angle = radians
    @cos = Math.cos(@turtle_angle)
    @sin = Math.sin(@turtle_angle)
  end
  
  def name_for_to? symbol
    symbol == :to
  end
  
  def method_missing sym, *args, &block
    
    if SHORTCUTS.key?(sym)
      self.send SHORTCUTS[sym], *args
    elsif @procedures.key?(sym)
      @procedures[sym].execute(*args)
    elsif name_for_to?(sym)
      
      super unless @pending_procedures
      
      @procedures[@pending_procedures.name] = @pending_procedures
      
      @pending_procedures = nil
      
    else
      @pending_procedures = Procedure.new(sym, args, &block)
    end
    
  end
  
  def theme name = nil

    name = name.name if name.is_a?(Procedure)

    return if name.nil? or @theme == name
    return unless THEMES.key?(name)
    
    @theme = name
    @graphics[:surface].repaint
    
  end
  
  class Procedure
    
    attr_reader :name
    
    def initialize name, params, &body
    
      @name, @params = name, params
      
      params.each { |p| raise "Invalid procedure definition, unexpected #{p}" unless p.is_a?(Symbol) }
      
      @body = body
      
    end
    
    def execute *args
      
      raise "Missing arguments, expected #{@params.length} but was #{args.length}" if args.length < @params.length
      raise "Too many arguments, expected #{@params.length} but was #{args.length}" if args.length > @params.length
      
      bound_self = eval('self', @body.binding)
      
      i = 0
      
      @params.each do |p|
        
        bound_self.instance_variable_set("@#{p}".to_sym, args[i])
        
        i += 1
        
      end
      
      @body.call
      
    end
    
  end
  
  TRUTLE_WIDTH = 16
  TRUTLE_HEIGHT = 18
  
  def paint_turtle x, y, gr

    return unless @visible_turtle
    
    gr.rotate -(@turtle_angle - Math::PI / 2), x, y
    
    x -= TRUTLE_WIDTH / 2
    y -= TRUTLE_HEIGHT / 2
    
    middle = x + TRUTLE_WIDTH / 2
    
    gr.stroke_width 2
    
    gr.fill_oval middle - 3, y - 7, 6, 6
    
    gr.draw_line middle, y - 2, middle, y
    
    gr.draw_line x, y, x + TRUTLE_WIDTH - 1, y + TRUTLE_HEIGHT - 1
    gr.draw_line x + TRUTLE_WIDTH, y, x - 1, y + TRUTLE_HEIGHT - 1
    
    gr.fill_oval x, y, TRUTLE_WIDTH, TRUTLE_HEIGHT
    
  end
  
end
