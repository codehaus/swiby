#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby
    
  class Section < SwingBase
    
    def initialize title

      @component = JPanel.new
      @component.border = ::BorderFactory.createTitledBorder(title) unless title.nil?

      @kids = []
      
    end
    
    def layout= layout_manager
      @component.layout = layout_manager
    end
    
    def add child
      @kids << child
      @component.add child.java_component
    end
    
    def java_container
      @component
    end
    
    def text
      @component.border.title unless @component.border.nil?
    end
    
    def text= t
      @component.border.title = t
    end

    def apply_styles styles

      return unless styles
      
      if @component.border
        color = styles.resolver.find_color(:border)
        @component.border.title_color = color if color
      
        font = styles.resolver.find_font(:container)
        @component.border.title_font = font if font
      end
      
      color = styles.resolver.find_background_color(:container)
      @component.background = color if color
      
      @kids.each do |child|
        child.apply_styles styles
      end
      
    end
    
  end

end