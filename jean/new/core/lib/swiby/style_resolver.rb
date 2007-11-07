#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby

  module AWT
    include_class 'java.awt.Font'
  end
  
  class StyleResolver

    def self.resolve component_type

      root = styles.root

      x = styles.send(component_type)

      x = root unless x

      return nil unless x
      
      yield root, x
      
    end
    
    def self.color component_type
      
      resolve(component_type) do |root, x|
        
        color = x.color
        color = root.color unless color
        
        return nil unless color
        
        AWT::Color.new color
        
      end
      
    end
    
    def self.background_color component_type
      
      resolve(component_type) do |root, x|
        
        color = x.background_color
        color = root.background_color unless color
        
        return nil unless color
        
        AWT::Color.new color
        
      end
      
    end
    
    def self.font component_type

      resolve(component_type) do |root, x|

        size = x.font_size
        size = root.font_size unless size
        style = x.font_style
        style = root.font_style unless style
        weight = x.font_weight
        weight = root.font_weight unless weight

        if style.nil? and weight.nil?
          style = AWT::Font::PLAIN
        else

          awt_style = 0

          if style == :italic
            awt_style = AWT::Font::ITALIC
          end

          if weight == :bold
            awt_style += AWT::Font::BOLD
          end

        end

        family = x.font_family
        family = root.font_family unless family

        return nil unless family and size

        AWT::Font.new(family, awt_style, size) #TODO use a cache for the fonts?
        
      end

    end

  end

end