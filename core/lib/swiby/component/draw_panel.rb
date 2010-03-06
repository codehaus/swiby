#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby'
require 'swiby/2d'

class DrawPanel < javax.swing.JComponent

  include MouseListener
  include MouseMotionListener
 
  attr_accessor :style_class, :resize_always
  
  def initialize
    @resize_always = false
    @mouse_installed = false
    @mouse_motion_installed = false
  end
 
  def java_component force_no_scroll = false
    self
  end
    
  def change_language
  end
  
  def apply_styles styles
    
    @on_styles.call(styles) if @on_styles
      
    border = styles.resolver.create_border(:table, @style_id, @style_class)
      
    self.border = border if border
    
    repaint
    
  end
  
  def layer name
    @graphics[name] if @graphics
  end
    
  def paintComponent g

    #TODO how to call super paintComponent ?
   
    if @painter
   
      @graphics = Graphics.new(self, g, @resize_always) unless @graphics
      @graphics.set_java_graphics g
    
      @painter.call(@graphics)
     
      @graphics.render
     
    end
  
    paintComponents g
    
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
  
    class DrawPanelOptions < ComponentOptions
        
      define "DrawPanel" do
        
        declare :width, [Integer], true
        declare :height, [Integer], true
        declare :name, [String, Symbol], true
        declare :painter, [Proc], true
        declare :resize_always, [TrueClass, FalseClass], true
        
        overload :name
        overload :painter

      end
      
    end
    
    def draw_panel name = nil, options = nil, &painter
  
      ensure_section
      
      x = DrawPanelOptions.new(context, name, options, &painter)
      
      panel = DrawPanel.new
      
      panel.preferred_size = Dimension.new(x[:width], x[:height]) if x[:width] and x[:height]
      
      panel.on_paint &x[:action] if x[:action]
      panel.resize_always = x[:resize_always] if x[:resize_always]
      
      panel.name = x[:name].to_s if x[:name]
      context[x[:name].to_s] = panel if x[:name]
      
      context.add_child panel
      
      add panel
      context << panel
      layout_panel panel
      
      panel
      
    end
    
  end
  
end