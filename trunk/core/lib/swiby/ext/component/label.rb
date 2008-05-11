#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import javax.swing.BorderFactory

module Swiby
  
  class LabelExtension < Extension
    include ComponentExtension
  end

  module Builder

    def layout_label label
    end
        
    def label text = nil, options = nil, &block

      ensure_section

      x = LabelOptions.new(context, text, options, &block)

      set_context(x[:action]) if x[:action]
      
      label = SimpleLabel.new(x)

      context[x[:name].to_s] = label if x[:name]
      
      context.add_child label
      
      add label
      context << label
      layout_label label

    end

  end

  class LabelOptions < ComponentOptions
      
    define "Label" do
      
      declare :swing, [Proc], true
      declare :action, [Proc], true
      declare :name, [String, Symbol], true
      declare :label, [String, Symbol, IncrementalValue]
      
      overload :label
      overload :label, :name

    end
    
  end

  class SimpleLabel < SwingBase

    def initialize options = nil
      
      @component = JLabel.new
      
      return unless options

      if options[:label]
        
        x = options[:label]
        
        if x.instance_of? IncrementalValue
          x.assign_to self, :text=
        else
          self.text = x
        end
        
      end

      self.linked_field = options[:input_component] if options[:input_component]
      self.name = options[:name].to_s if options[:input_component].nil? && options[:name]

      @style_id = self.name.to_sym if self.name
      
      action(&options[:action]) if options[:action]
      
      options[:swing].call(java_component) if options[:swing]
      
    end

    def apply_styles styles
      
      return unless styles

      if Defaults.enhanced_styling?
        font = styles.resolver.find_css_font(:label, @style_id)
        @component.text = "#{font}#{@real_text}" if font
      else
        font = styles.resolver.find_font(:label, @style_id)
        @component.font = font if font
      end
      
      color = styles.resolver.find_color(:label, @style_id)
      @component.foreground = color if color
      
      border = styles.resolver.create_border(:label, @style_id)
        
      @component.border = border if border
      
    end
    
    def action(&block)

      listener = MouseListener.new

      @component.addMouseListener(listener)

      block.instance_eval(&block)
      
      listener.register(&block)

    end

    def linked_field=(comp)
      comp.linked_label = self
      @linked_field = comp
      @component.set_label_for(comp.java_component)
    end
    
    def linked_field
      @linked_field
    end

    def text=(t)

      #TODO is here the right place for this decision? (using IncrementalValue, raw value or HTML)
      if t.instance_of? IncrementalValue
        t.assign_to self, :text=
      elsif t.instance_of? String
        t = ERB.new(t).result #TODO use if HTML not only in Label + maybe ERB is too much if simple string?
      end
      
      @real_text = t
      @component.text = t
      
    end

    def text
      @real_text
    end

  end
  
end