#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

include Java

import java.awt.Font
import java.awt.AWTEvent
import java.awt.FontMetrics
import java.awt.Dimension
import java.awt.RenderingHints

import java.awt.BasicStroke

import java.awt.event.MouseListener
import java.awt.event.MouseMotionListener

class ImagePainter
  
  include javax.swing.Icon
  
  attr_reader :painter
  
  def initialize painter, width, height
    @painter, @width, @height = painter, width, height
  end
  
  def paintIcon(component, graphics, x, y)
    
    if @wrapper
      @wrapper.set_java_graphics graphics
    else
      @wrapper = Graphics.new(component, graphics)
    end
    
    @painter.paint @wrapper
    
    @wrapper.render x, y
    
  end
  
  def getIconWidth()
    @width
  end
  
  def getIconHeight()
    @height
  end
  
end

class GraphicsLayer
  
  attr_accessor :image
  
  def initialize component, image
    @comp, @image, @dirty = component, image, true
  end
  
  def dirty?
    @dirty
  end
  def dirty= set
    @dirty = set
  end
  
  def repaint
    @dirty = true
    @comp.repaint
  end
  
end

class DrawPen

  attr_reader :x, :y
  
  def initialize comp, gr, x = 0, y = 0
    @comp = comp
    @gr = gr
    @x = x
    @y = y
    @pen_down = false
  end
  
  def font name, style = nil, size = nil
    @gr.set_font name, style, size
  end
  
  def line_style style = :continuous
    @gr.line_style style
  end
  
  def up
    @pen_down = false
  end
 
  def down
    @pen_down = true
  end 
  
  def move_to x, y
   
    if @pen_down
      @gr.draw_line @x, @y, x, y
    end
   
    @x = x
    @y = y
   
  end
  
  def color col
    @gr.color col
  end
  
  def stroke_width width = 1
    @gr.stroke_width width
  end
  
  # (self..x, self.y, width, height) specify the enclosing rectangle
  # angels are degrees
  def arc width, height, starting_angle, arc_angle
    
    return unless @pen_down
    
    @gr.draw_arc @x, @y, width, height, starting_angle, arc_angle
    
  end
  
  # (self..x, self.y, width, height) specify the enclosing rectangle
  # angels are degrees
  def fill_arc width, height, starting_angle, arc_angle
    
    return unless @pen_down
    
    @gr.fill_arc @x, @y, width, height, starting_angle, arc_angle
    
  end
  
  def oval width, height, border_width = nil, border_color = nil
    
    return unless @pen_down
    return if border_width == 0
    
    save_color = @gr.color
    @gr.stroke_width border_width if border_width
    @gr.color border_color if border_color
    @gr.draw_oval @x, @y, width, height if @pen_down
    @gr.color save_color
    
  end
  
  def fill_oval width, height
    @gr.fill_oval @x, @y, width, height if @pen_down    
  end

  def rect width, height
    @gr.draw_rect @x, @y, width, height if @pen_down    
  end

  def fill_rect width, height
    @gr.fill_rect @x, @y, width, height if @pen_down    
  end

  # +arc_width+ horizontal diameter of the arc for the round corners
  # +arc_height+ vertical diameter of the arc for the round corners
  def round_rect w, h, arc_width, arc_height
    @gr.draw_round_rect @x, @y, w, h, arc_width, arc_height if @pen_down
  end
  
  # +arc_width+ horizontal diameter of the arc for the round corners
  # +arc_height+ vertical diameter of the arc for the round corners
  def fill_round_rect w, h, arc_width, arc_height
    @gr.fill_round_rect @x, @y, w, h, arc_width, arc_height if @pen_down
  end
  
  def polygon poly
    @gr.draw_polygon poly
  end
  
  def fill_polygon poly
    @gr.fill_polygon poly
  end
  
  def draw_image img
    @gr.draw_image @x, @y, img
  end

  def write text
    @gr.draw_string text, @x, @y
  end
 
  def centered text
    @gr.centered_string text, @x, @y
  end
  
  def box w, h, text = nil
  
    @gr.draw_rect @x, @y, w, h
  
    if text
  
      rect = @gr.string_bounds(text)
    
      text_height = rect.height
      text_width = rect.width
    
      @x += (w - text_width)  / 2
      @y += (h - text_height) / 2  + @gr.ascent
  
      write text
    
    end
  
  end
 
end

class Graphics

  def initialize comp, gr, resize_always = false, parent = nil
    @comp = comp
    @gr = gr
    @pen_down = false
    @resized = true
    @layers = {}
    @parent = parent
    @pending_off_image = nil
    @resize_always = resize_always
  end
 
  def self.create_font name, style = Font::PLAIN, size = 10
    Font.new(name, style, size)
  end

  def render x = 0, y = 0
    @gr.drawImage(@pending_off_image, x, y, @comp) if @pending_off_image
    @pending_off_image = nil
  end

  def create_pen x = 0, y = 0
    DrawPen.new(@comp, self, x, y)    
  end
  
  def [] layer_name
    @layers[layer_name]
  end
  
  def resize_always= enable
    @resize_always= enable
  end
  
  def drawing_width
    if @parent
      @parent.drawing_width
    else
      @drawing_width
    end
  end
  
  def drawing_height
    if @parent
      @parent.drawing_height
    else
      @drawing_height
    end
  end
  
  def drawing_size drawing_width, drawing_height
    @drawing_width, @drawing_height = drawing_width, drawing_height
  end
  
  def layer name = :default, force_paint = false
 
    if name == :default
   
      render
   
      yield self
     
    else
   
      layer = @layers[name]
      off_image = layer ? layer.image : nil
   
      force_paint = layer ? (force_paint or layer.dirty?) : force_paint
      
      unless off_image.nil? 
        resized = off_image.width < width || off_image.height < height
        resized = (resized || off_image.width > width || off_image.height > height) if @resize_always
      end
      
      if off_image.nil? or resized

        off_image = @comp.createImage width, height
        layer = GraphicsLayer.new(@comp, off_image)
        
        @layers[name] = layer
       
        off_gr = off_image.createGraphics
        graphics = Graphics.new(@comp, off_gr, @resize_always, self)
       
        force_paint = true
       
      elsif force_paint
       
        off_gr = off_image.createGraphics
        graphics = Graphics.new(@comp, off_gr, @resize_always, self)
       
        graphics.resized = false
       
      end
     
      layer.dirty = false
      
      if force_paint
       
        off_gr.drawImage(@pending_off_image, 0, 0, @comp) if @pending_off_image
        @pending_off_image = nil
       
        dw = self.drawing_width
        dh = self.drawing_height
        
        if dw and dh
          
          unless graphics.width == dw and graphics.height == dh
            
            scale_x = graphics.width / self.drawing_width.to_f
            scale_y = graphics.height / self.drawing_height.to_f

            graphics.scale scale_x, scale_y
            
          end
          
        end
  
        yield graphics
       
        off_gr.dispose
       
      end

      @pending_off_image = off_image
       
    end
   
  end
 
  def set_java_graphics gr
    @gr = gr
  end
 
  def resized?
    @resized
  end
 
  def resized= flag
    @resized = flag
  end
   
  def set_font name, style = nil, size = nil
    
    @fm = nil
    
    if style
      @gr.font = Graphics.create_font(name, style, size)
    else
      @gr.font = name
    end
    
  end
 
  def width
    
    w = @comp.width
    
    if @comp.border
      b = @comp.border
      w -= b.getBorderInsets(@comp).left + b.getBorderInsets(@comp).right
    end
    
    w
    
  end
 
  def height
    
    h = @comp.height
    
    if @comp.border
      b = @comp.border
      h -= b.getBorderInsets(@comp).top + b.getBorderInsets(@comp).bottom
    end
    
    h
    
  end
 
  def antialias= flag
    @gr.set_rendering_hint(RenderingHints::KEY_ANTIALIASING, RenderingHints::VALUE_ANTIALIAS_ON) if flag
  end
  
  def clear w = nil, h = nil
    
    unless w
      w = drawing_width 
    w = width unless w
      h = drawing_height 
    h = height unless h
    end
    
    @gr.clear_rect 0, 0, w, h
    
  end
  
  def color color = nil
    return @gr.color unless color
    @gr.set_color color
  end
  
  def background color
    return @gr.background unless color
    @gr.set_background color
  end
  
  def string_bounds text
    @fm = @gr.getFontMetrics(@gr.font) unless @fm
    @fm.getStringBounds(text, @gr)
  end
 
  def ascent
    @fm = @gr.getFontMetrics(@gr.font) unless @fm
    @fm.ascent
  end
  
  def draw_string text, x, y
    @gr.drawString text, x, y
  end
  
  def draw_glyph glyph_code, x, y
    draw_glyphs [glyph_code], x, y
  end
  
  def draw_glyphs glyphs, x, y
    
    glyphs = glyphs.to_java :int
    
    frc = @gr.getFontRenderContext
    glyphs = @gr.getFont.createGlyphVector(frc, glyphs)
    
    @gr.drawGlyphVector(glyphs, x, y)
      
  end
  
  def centered_string text, x, y
    
    rect = string_bounds(text)
    
    x -= rect.width / 2
    y += (rect.height - ascent / 2) / 2

    draw_string text, x, y
  
  end
 
  # line possible values are :continuous, :dash
  def line_style style = :continuous
    
    if style == :continuous
      @gr.setStroke(@line_stroke) if @line_stroke
    else
      
      unless @line_stroke
      
        @line_stroke = @gr.getStroke
      
        dash1 = [5].to_java(:float)
        
        @dash_stroke = BasicStroke.new(1, BasicStroke::CAP_BUTT, BasicStroke::JOIN_MITER, 10, dash1, 0)
      
      end
      
      @gr.setStroke(@dash_stroke)
      
    end
    
  end
 
  def stroke_width width = 1, cap = nil, join = nil
    
    stroke = cap ? BasicStroke.new(width, cap, join) : BasicStroke.new(width)
    
    @gr.setStroke(stroke)
    
  end
  
  def draw_line x1, y1, x2, y2
    @gr.draw_line x1, y1, x2, y2
  end
  
  def translate x, y
    @gr.translate(x, y)
  end
  
  def rotate angle, x = nil, y = nil
    
    if x
      @gr.rotate angle, x, y
    else
      @gr.rotate angle
    end
    
  end
  
  # if scale_y is nil apply the same scaling in both direction
  def scale scale_x, scale_y = nil
    scale_y = scale_x unless scale_y
    @gr.scale scale_x, scale_y
  end
  
  def polygon *points
    
    poly = java.awt.Polygon.new
    
    points.each { |x, y| poly.add_point x, y }
    
    poly
    
  end
  
  def draw_rect x, y, w, h
    @gr.draw_rect x, y, w, h
  end
  
  def fill_rect x, y, w, h
    @gr.fill_rect x, y, w, h
  end
  
  # +arc_width+ horizontal diameter of the arc for the round corners
  # +arc_height+ vertical diameter of the arc for the round corners
  def draw_round_rect x, y, w, h, arc_width, arc_height
    @gr.draw_round_rect x, y, w, h, arc_width, arc_height
  end
  
  # +arc_width+ horizontal diameter of the arc for the round corners
  # +arc_height+ vertical diameter of the arc for the round corners
  def fill_round_rect x, y, w, h, arc_width, arc_height
    @gr.fill_round_rect x, y, w, h, arc_width, arc_height
  end
  
  def draw_polygon poly
    @gr.draw_polygon poly
  end
  
  def fill_polygon poly
    @gr.fill_polygon poly
  end
  
  def draw_oval x, y, width, height
    @gr.drawOval x, y, width, height
  end

  def fill_oval x, y, width, height
    @gr.fillOval x, y, width, height
  end

  # (x, y, width, height) specify the enclosing rectangle
  # angels are degrees
  def draw_arc x, y, width, height, starting_angle, arc_angle
    @gr.drawArc x, y, width, height, starting_angle, arc_angle
  end
  
  # (x, y, width, height) specify the enclosing rectangle
  # angels are degrees
  def fill_arc x, y, width, height, starting_angle, arc_angle
    @gr.fillArc x, y, width, height, starting_angle, arc_angle
  end
  
  def draw_image x, y, img
    @gr.drawImage img.getImage, x, y, @comp
  end

  def gradient start_x, start_y, start_color, end_x, end_y, end_color, cyclic = true
    p = java.awt.GradientPaint.new(start_x, start_y, start_color, end_x, end_y, end_color, cyclic)
    @gr.setPaint(p)
  end
  
  def repaint
    @comp.repaint
  end
   
end
