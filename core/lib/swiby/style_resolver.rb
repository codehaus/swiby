#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/styles'

module Swiby

  module AWT
    include_class 'java.awt.Font'
  end
  
  class StyleResolver

    def initialize styles
      @styles = styles
      @cache = {}
    end
    
    def resolve component_type

      root = @styles.root if @styles.has_element?(:root)

      x = @styles.send(component_type) if @styles.has_element?(component_type)
      
      x = root unless x

      return nil unless x

      yield root, x
      
    end

    def find element, component_type, id = nil

      if id and @styles.has_class?(id)

        styles = @styles[id]

        value = styles.resolver.find(element, component_type)

        return value if value

      end

      resolve(component_type) do |root, x|

        value = x.send(element)
        value = root.send(element) unless root.nil? or value

        value

      end

    end
    
    def find_color component_type, id = nil
      
      color = find(:color, component_type, id)
      
      create_color(color)
      
    end
    
    def find_background_color component_type, id = nil
      
      color = find(:background_color, component_type, id)
      
      create_color(color)
      
    end
    
    def find_font component_type, id = nil
      
      size = find(:font_size, component_type, id)
      style = find(:font_style, component_type, id)
      weight = find(:font_weight, component_type, id)

      family = find(:font_family, component_type, id)

      if style.nil? and weight.nil?
        style = AWT::Font::PLAIN
      else

        awt_style = 0

        if style == :normal
          awt_style = AWT::Font::PLAIN
        end

        if style == :italic
          awt_style = AWT::Font::ITALIC
        end

        if weight == :bold
          awt_style += AWT::Font::BOLD
        end

      end

      create_font(family, awt_style, size)

    end

    def find_css_font component_type, id = nil

      size = find(:font_size, component_type, id)
      style = find(:font_style, component_type, id)
      weight = find(:font_weight, component_type, id)
      decoration = find(:text_decoration, component_type, id)

      family = find(:font_family, component_type, id)

      css = ""
      
      css += "font-size: #{size};" if size
      css += "font-style: #{style};" if style
      css += "font-weight: #{weight};" if weight
      css += "font-family: #{family};" if family
      css += "text-decoration: #{decoration};" if decoration

      "<html><style>body {#{css}}<body>"

    end

    def create_border element, id = nil
      
      margin = find(:margin, element, id)
      padding = find(:padding, element, id)
      color = find(:border_color, element, id)
      
      color = create_color(color) if color
      border_color = ::BorderFactory.createLineBorder(color) if color
      border_margin = ::BorderFactory.createEmptyBorder(margin, margin, margin, margin) if margin
      border_padding = ::BorderFactory.createEmptyBorder(padding, padding, padding, padding) if padding
        
      if border_margin and border_color
        border = ::BorderFactory.createCompoundBorder(border_margin, border_color)
      elsif border_color
        border = border_color
      elsif border_margin
        border = border_margin
      end
      
      if border_padding and border
        border = ::BorderFactory.createCompoundBorder(border, border_padding)
      elsif border_padding
        border = border_padding
      end

      border
      
    end
    
    def create_color color

      return nil unless color
      return color if color.is_a?(::Java::JavaAwt::Color)

      return @cache[color] if @cache.has_key?(color)

      if color.is_a?(Symbol)
        value = eval("AWT::Color::#{color}")
      else
        value = AWT::Color.new(color)
      end

      @cache[color] = value

    end

    def create_font family, awt_style, size

      return nil unless family and size

      font_key = [family, awt_style, size]

      return @cache[font_key] if  @cache.has_key?(font_key)

      font = AWT::Font.new(family, awt_style, size) #TODO use a global cache for the fonts?

      @cache[font_key] = font

    end

  end
  
end