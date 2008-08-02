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
import java.awt.RenderingHints

import java.awt.BasicStroke

import java.awt.event.MouseListener
import java.awt.event.MouseMotionListener

class Graphics

  def initialize comp, gr
    @comp = comp
    @gr = gr
    @x = 0
    @y = 0
    @pen_down = false
    @resized = true
    @layers = {}
    @pending_off_image = nil
  end
 
  def create_font name, style, size
    Font.new(name, style, size)
  end

  def render
    @gr.drawImage(@pending_off_image, 0, 0, @comp) if @pending_off_image
    @pending_off_image = nil
  end
 
  def layer name = :default, force_paint = false
 
    if name == :default
   
      render
   
      yield self
     
    else
   
      off_image = @layers[name]
   
      if off_image.nil? or off_image.width < width or off_image.height < height
       
        off_image = @comp.createImage width, height
        @layers[name] = off_image
       
        off_gr = off_image.createGraphics
        graphics = Graphics.new @comp, off_gr
       
        force_paint = true
       
      elsif force_paint
       
        off_gr = off_image.createGraphics
        graphics = Graphics.new @comp, off_gr
       
        graphics.resized = false
       
      end
     
      if force_paint
       
        off_gr.drawImage(@pending_off_image, 0, 0, @comp) if @pending_off_image
        @pending_off_image = nil
       
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
   
  def set_font name, style, size
    @fm = nil
    @gr.font =  create_font(name, style, size)
  end
 
  def width
    @comp.width
  end
 
  def height
    @comp.height
  end
 
  def antialias= flag
    @gr.set_rendering_hint(RenderingHints::KEY_ANTIALIASING, RenderingHints::VALUE_ANTIALIAS_ON) if flag
  end
  
  def clear
    @gr.clear_rect 0, 0, width, height    
  end
  
  def color color
    @gr.set_color color
  end
  
  def background color
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
 
  def up
    @pen_down = false
  end
 
  def down
    @pen_down = true
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
  
  def move_to x, y
   
    if @pen_down
      render
      @gr.draw_line @x, @y, x, y
    end
   
    @x = x
    @y = y
   
  end
 
  def draw_image img
    @gr.drawImage img.getImage, @x, @y, @comp
  end

  def draw text
    render
    @gr.drawString text, @x, @y
  end
 
  def box w, h, text = nil
  
    render
     
    @gr.draw_rect @x, @y, w, h
  
    if text
  
      rect = self.string_bounds(text)
    
      text_height = rect.height
      text_width = rect.width
    
      @x += (w - text_width)  / 2
      @y += (h - text_height) / 2  + ascent
  
      draw text
    
    end
  
  end
 
end

class DrawPanel < javax.swing.JComponent

  include MouseListener
  include MouseMotionListener
 
  def initialize
    @mouse_installed = false
    @mouse_motion_installed = false
  end
 
  def java_component
    self
  end

  def apply_styles styles
    
    @on_styles.call(styles) if @on_styles
      
    border = styles.resolver.create_border(:table, @style_id)
      
    self.border = border if border
    
    repaint
    
  end
  
  def paintComponent g

    # how to cal super paintComponent ?
   
    if @painter
   
      @graphics = Graphics.new(self, g) unless @graphics
      @graphics.set_java_graphics g
    
      @painter.call(@graphics)
     
      @graphics.render
     
    end
  
  end
 
  def on_styles &block
    @on_styles = block
  end
  
  def on_paint &block
    @painter = block
  end
 
  def on_click &block
    addMouseListener self unless @mouse_installed
    @on_click = block
    @mouse_installed = true
  end
 
  def on_mouse_move &block
    addMouseMotionListener self unless @mouse_motion_installed
    @on_move = block
    @mouse_motion_installed = true
  end

  def on_mouse_over &block
    addMouseMotionListener self unless @mouse_motion_installed
    @on_over = block
    @mouse_motion_installed = true
  end

  def on_mouse_up &block
    addMouseListener self unless @mouse_installed
    @on_up = block
    @mouse_installed = true
  end
 
  def mouseClicked ev
    @on_click.call(ev.getX(), ev.getY()) if @on_click
  end

  def mouseEntered ev
  end

  def mouseExited ev
  end

  def mousePressed ev
  end

  def mouseReleased ev
    @on_up.call(ev.getX(), ev.getY()) if @on_up
  end
 
  def mouseDragged ev
    @on_move.call(ev.getX(), ev.getY()) if @on_move
  end

  def mouseMoved ev
    @on_over.call(ev.getX(), ev.getY()) if @on_over
  end
 
end
 
module Swiby

  module Builder
    
    def draw_panel name = nil
  
      panel = DrawPanel.new
      
      context[name.to_s] = panel if name
      
      context.add_child panel
      
      add panel
      context << panel
      layout_panel panel
      
      panel
      
    end
    
  end
  
end