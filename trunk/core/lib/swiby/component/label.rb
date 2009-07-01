#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import javax.swing.JLabel
import javax.swing.ImageIcon
import javax.swing.BorderFactory

module Swiby

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
      
      label

    end
    
    def hover_label text = nil, options = nil, &block
      
      handler = block
      hover_color = Color::RED
      
      if options and options.respond_to?(:[])
        
        if options[:action]
          handler = options[:action]
          options.delete :action
        end
        
        if options[:hover_color]
          hover_color = options[:hover_color]
          options.delete :hover_color
        end
        
      end
      
      l = label(text, options)
              
      if handler
        l.action do
          
          @label = l
          @handler = handler
          @color = hover_color
          
          def on_click ev
            on_mouse_out nil # simulate mouse out
            @handler.call
          end
          
          def on_mouse_over ev
            return if @is_over
            @is_over = true
            @normal_color = @label.java_component.foreground
            @label.java_component.foreground = @color
          end
          
          def on_mouse_out ev
            return unless @is_over
            @is_over = false
            @label.java_component.foreground = @normal_color
          end
        
        end
      end
      
    end

  end

  class LabelOptions < ComponentOptions
      
    define "Label" do
      
      declare :swing, [Proc], true
      declare :action, [Proc], true
      declare :icon, [ImageIcon], true
      declare :name, [String, Symbol], true
      declare :label, [String, Symbol, IncrementalValue], true
      declare :style_class, [String, Symbol], true
      
      overload :label
      overload :icon
      overload :label, :name
      overload :icon, :name

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

      @component.icon = options[:icon] if options[:icon]
      
      self.linked_field = options[:input_component] if options[:input_component]
      self.name = options[:name].to_s if options[:input_component].nil? && options[:name]

      @style_id = self.name.to_sym if self.name
      @style_class = options[:style_class] if options[:style_class]
      
      action(&options[:action]) if options[:action]
      
      options[:swing].call(java_component) if options[:swing]
      
    end

    def apply_styles styles
      
      return unless styles

      if Defaults.enhanced_styling?
        font = styles.resolver.find_css_font(:label, @style_id, @style_class)
        @component.text = "#{font}#{@real_text}" if font
      else
        font = styles.resolver.find_font(:label, @style_id, @style_class)
        @component.font = font if font
      end
      
      color = styles.resolver.find_color(:label, @style_id, @style_class)
      @component.foreground = color if color
      
      border = styles.resolver.create_border(:label, @style_id, @style_class)
        
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