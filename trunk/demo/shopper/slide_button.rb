#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby
  
  module Builder
    
    def slide_button label, yes_text, no_text = nil
      
      ensure_section
      
      if no_text.nil?
        no_text = yes_text
        yes_text = label
        label = nil
      end
      
      but = SlideButton.new(yes_text, no_text)
      
      if label
        label = SimpleLabel.new({:label => label})
        add label
        context << label
        context.add_child label
      end
        
      #context[options[:name].to_s] = but if options[:name]
      
      context.add_child but
      
      add but
      context << but
      
      layout_input label, but
      
    end
    
  end

  class SlideButton < SwingBase
    
    def initialize yes_text, no_text
      @component = org.codehaus.swiby.component.SlideButton.new(yes_text, no_text)
    end
    
    def apply_styles styles
      
      return unless styles
        
      font = styles.resolver.find_font(:button, @style_id, @style_class)
      @component.font = font if font
        
      color = styles.resolver.find_color(:button, @style_id, @style_class)
      @component.foreground = color if color
      
    end
    
  end
  
end
