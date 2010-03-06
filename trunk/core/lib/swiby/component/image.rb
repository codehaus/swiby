#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/util/developer'

require 'swiby/mvc/list'

import java.awt.Color
import java.awt.GradientPaint
import java.awt.image.BufferedImage

import javax.swing.JList
import javax.swing.JScrollPane
import javax.swing.ScrollPaneConstants

import javax.swing.ImageIcon

import com.sun.javaone.aerith.ui.GradientViewport
import com.sun.javaone.aerith.ui.plaf.AerithScrollbarUI

module Swiby

  #
  # Based on "Fun with Java2D - Java Reflections" from Jerry Huxtable
  #    at http://www.jhlabs.com/java/java2d/reflections/index.html
  #
  class ReflectivePanel < javax.swing.JComponent
    
    attr_accessor :image_width
    attr_accessor :margin_top, :relection_gap
    attr_accessor :gradient_color_from, :gradient_color_to, :gradient_direction
    
    def initialize
      @margin_top = 20
      @relection_gap = 20
      @gradient_direction  = :vertical
      @gradient_color_from = Color::BLACK
      @gradient_color_to = Color::DARK_GRAY
    end
    
    def image= image
      @image = image
      @need_to_scale = true
      convert
      repaint
    end
    
    def convert
       
      if @image.is_a?(ImageIcon)
        
        image = createImage(@image.getIconWidth, @image.getIconHeight)
        
        return false unless image
       
        g = image.createGraphics
        g.drawImage(@image.getImage, 0, 0, self)
        g.dispose
        
        @image = image
        
      end
      
      if @need_to_scale and @image_width and @image.getWidth > @image_width
        
        h = (@image_width * @image.getHeight) / @image.getWidth
        
        image = createImage(@image_width, h)
        
        return false unless image
       
        g = image.createGraphics
        g.drawImage(@image,
                    0, 0, @image_width, h,
                    0, 0, @image.getWidth, @image.getHeight, self)
        g.dispose
        
        @image = image
        @need_to_scale = false
        
      end
      
      true
      
    end
    
    def paintComponent g
 
      return unless convert
      
      opacity = 0.4
      fadeHeight = 0.3

      case @gradient_direction
        when :vertical
          p = GradientPaint.new(0, 0, @gradient_color_from, 0, height, @gradient_color_to)
        when :horizontal
          p = GradientPaint.new(0, 0, @gradient_color_from, width, 0, @gradient_color_to)
        when :diagonal_to_top
          p = GradientPaint.new(0, height, @gradient_color_from, width, 0, @gradient_color_to)
        when :diagonal_to_bottom
          p = GradientPaint.new(0, 0, @gradient_color_from, width, height, @gradient_color_to)
      end
      
      g.paint = p
      g.fillRect 0, 0, width, height
    
      return unless @image
      
      imageWidth = @image.getWidth()
      imageHeight = @image.getHeight()
      
      g.translate((width-imageWidth)/2, @margin_top)
      g.drawRenderedImage(@image, nil)

      reflection = BufferedImage.new(imageWidth, imageHeight, BufferedImage::TYPE_INT_ARGB)
      rg = reflection.createGraphics()
      rg.drawRenderedImage(@image, nil)
      rg.setComposite(java.awt.AlphaComposite.getInstance(java.awt.AlphaComposite::DST_IN))
      rg.setPaint( 
        GradientPaint.new( 
          0, imageHeight*fadeHeight, java.awt.Color.new(0.0, 0.0, 0.0, 0.0),
          0, imageHeight, java.awt.Color.new(0.0, 0.0, 0.0, opacity)
        )
      )
      rg.fillRect(0, 0, imageWidth, imageHeight)
      rg.dispose
      
      g.translate(0, 2*imageHeight+@relection_gap)
      g.scale(1, -1)
      
      g.drawRenderedImage( reflection, nil )
    
    end
    
  end
  
  class ImagePanel < SwingBase
  
    def initialize image, options = nil

      @component = ReflectivePanel.new
      
      @component.image = image
      
      return unless options
      
      self.name = options[:name].to_s if options[:name]
      
      @style_id = self.name.to_sym if self.name
      @style_class = options[:style_class] if options[:style_class]
      
      @component.image_width = options[:image_width] if options[:image_width]
      
      options[:swing].call(java_component) if options[:swing]
      
    end
    
    def image= image
      @component.image = image
    end
    
    def apply_styles styles = nil
      
      return unless styles or @styles
      
      color = styles.resolver.find(:background_gradient_from, :container, @style_id, @style_class)
      @component.gradient_color_from = styles.resolver.create_color(color) if color
      color = styles.resolver.find(:background_gradient_to, :container, @style_id, @style_class)
      @component.gradient_color_to = styles.resolver.create_color(color) if color
      direction = styles.resolver.find(:background_gradient_direction, :container, @style_id, @style_class)
      @component.gradient_direction = direction if direction 
      
      gap = styles.resolver.find(:relection_gap, :container, @style_id, @style_class)
      @component.relection_gap = gap if gap
      gap = styles.resolver.find(:margin_top, :container, @style_id, @style_class)
      @component.margin_top = gap
      
    end
    
  end
  
  module Builder
  
    def reflective_panel image = nil, options = nil
      
      ensure_section

      if image.is_a?(Hash)
        option = image
        image = nil
      end

      comp = ImagePanel.new(image, options)
      
      context.add_child comp
      
      add comp
      context << comp
      layout_label comp
      puts "TODO [#{__FILE__}] another layout, component"
      
      return unless options
      
      context[options[:name].to_s] = comp if options[:name]
      
      comp
      
    end
    
    # specific list options for the image list: :removal_gesture, :gradient_color, :item_layout
    def film_list images, *options
      merge_defaults!(options, :item_layout => :horizontal)
      create_image_list images, org.codehaus.swiby.component.FilmstripBorder.new, options
    end
    
    # specific list options for the image list: :removal_gesture, :gradient_color, :item_layout
    def slide_list images, *options
      merge_defaults!(options, :item_layout => :horizontal)
      create_image_list images, org.codehaus.swiby.component.SlideCacheBorder.new, options
    end
      
    # specific list options for the image list: :removal_gesture, :gradient_color, :item_layout
    def image_list images, *options
      merge_defaults!(options, :item_layout => :horizontal)
      create_image_list images, org.codehaus.swiby.component.DefaultSelectionBorder.new, options
    end
    
    # specific list options for the image list: :removal_gesture, :gradient_color, :item_layout
    def create_image_list images, border, options

      gradient_color = nil
      item_layout = :horizontal
      enable_removal_gesture = false
      
      if options[0].is_a?(Hash)
        
        params = options[0]
        
        if params[:gradient_color]
          gradient_color = params[:gradient_color]
          params.delete :gradient_color
        end
        
        if not params[:removal_gesture].nil?
          enable_removal_gesture = params[:removal_gesture] == true
          params.delete :removal_gesture
        end
        
        if not params[:item_layout].nil?
          item_layout = params[:item_layout]
          params.delete :item_layout
        end
        
      end
      
      comp = list(images, *options)
      
      scroll = comp.java_component
      imageList = comp.java_component(true)
      
      scroll.getViewport().setOpaque(false)
      imageList.setOpaque(false)
      
      case item_layout
        
        when :tile

          imageList.setLayoutOrientation(JList::HORIZONTAL_WRAP)
          scroll.setHorizontalScrollBarPolicy(ScrollPaneConstants::HORIZONTAL_SCROLLBAR_ALWAYS)
          scroll.setVerticalScrollBarPolicy(ScrollPaneConstants::VERTICAL_SCROLLBAR_ALWAYS)
          scroll.getHorizontalScrollBar.setUI(AerithScrollbarUI.new)
          scroll.getVerticalScrollBar.setUI(AerithScrollbarUI.new)
          
          s_bar_h = scroll.getHorizontalScrollBar.getPreferredSize
          s_bar_v = scroll.getVerticalScrollBar.getPreferredSize
          
          scroll.setViewport(GradientViewport.new(gradient_color, 45, GradientViewport::Orientation::HORIZONTAL)) if gradient_color
        
        when :horizontal
        
          imageList.setVisibleRowCount(1)
          imageList.setLayoutOrientation(JList::HORIZONTAL_WRAP)
          scroll.setHorizontalScrollBarPolicy(ScrollPaneConstants::HORIZONTAL_SCROLLBAR_ALWAYS)
          scroll.setVerticalScrollBarPolicy(ScrollPaneConstants::VERTICAL_SCROLLBAR_NEVER)
          scroll.getHorizontalScrollBar.setUI(AerithScrollbarUI.new)
          
          s_bar_h = scroll.getHorizontalScrollBar.getPreferredSize
          
          scroll.setViewport(GradientViewport.new(gradient_color, 45, GradientViewport::Orientation::HORIZONTAL)) if gradient_color
          
        else
          
          imageList.setLayoutOrientation(JList::VERTICAL)
          scroll.setVerticalScrollBarPolicy(ScrollPaneConstants::VERTICAL_SCROLLBAR_ALWAYS)
          scroll.setHorizontalScrollBarPolicy(ScrollPaneConstants::HORIZONTAL_SCROLLBAR_NEVER)
          scroll.getVerticalScrollBar.setUI(AerithScrollbarUI.new)
            
          s_bar_v = scroll.getVerticalScrollBar.getPreferredSize

          # aerith didn't implement VERTICAL gradient....
          #scroll.setViewport(GradientViewport.new(gradient_color, 45, GradientViewport::Orientation::VERTICAL)) if gradient_color
          
      end

      if border

        renderer = org.codehaus.swiby.component.ImageListCellRenderer.new(border)
        
        renderer.setImageRemovalGestureEnable(imageList, true) if enable_removal_gesture
        
        imageList.setCellRenderer(renderer)
        
      end

      scroll.getViewport.setView(imageList)
      
      insets = scroll.getInsets
      s2 = imageList.getPreferredSize
      
      if item_layout == :horizontal
        d = Dimension.new(s2.width + insets.left + insets.right, s_bar_h.height + s2.height + insets.top + insets.bottom)
      elsif item_layout == :vertical
        d = Dimension.new(s_bar_v.width + s2.width  + insets.left + insets.right, s_bar_v.height + insets.top + insets.bottom)
      else
        d = Dimension.new(s_bar_v.width + s2.width  + insets.left + insets.right, s_bar_h.height + s2.height + insets.top + insets.bottom)
      end

      scroll.setPreferredSize(d)

      comp
      
    end
    
  end

  def self.create_thumbnail image, thumbnail_width, as_image_icon = true
    
    height = (thumbnail_width * image.height) / image.width
    
    buffer = BufferedImage.new(thumbnail_width, height, BufferedImage::TYPE_INT_ARGB)
      
    g = buffer.createGraphics
    g.drawImage(image,
                  0, 0, thumbnail_width, height,
                  0, 0, image.width, image.height, nil)
    g.dispose

    return buffer unless as_image_icon
    
    ImageIcon.new(buffer) if as_image_icon
    
  end
  
end
