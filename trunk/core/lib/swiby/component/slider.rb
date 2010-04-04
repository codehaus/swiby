#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/label'

import javax.swing.JSlider

module Swiby
  
  module Builder
  
    def layout_button button
    end
    
    def slider orientation = nil, *options, &block

      ensure_section

      x = SliderOptions.new(context, orientation, *options, &block)
      
      comp = Slider.new(x)

      label = nil
      
      if x[:label]
        label = SimpleLabel.new(x)
        add label
        context << label
        context.add_child label
      end

      context[x[:name].to_s] = comp if x[:name]
      
      context.add_child comp
      
      add comp
      context << comp
      
      if label
        layout_input label, comp
      else
        layout_panel comp
      end
      
      comp
      
    end
  
  end
  
  class SliderOptions < ComponentOptions
    
    define "Slider" do
      
      declare :label, [String], true
      declare :minimum, [Fixnum], true
      declare :maximum, [Fixnum], true
      declare :value, [Fixnum], true
      declare :name, [String, Symbol], true
      declare :orientation, [Symbol], true
      declare :swing, [Proc], true
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      
      overload :label
      overload :orientation
      overload :label, :name
      overload :orientation, :name
      overload :orientation, :minimum, :name
      overload :orientation, :minimum, :maximum
      overload :orientation, :minimum, :maximum, :name
      overload :orientation, :minimum, :maximum, :value, :name
      
    end
    
  end

  class Slider < SwingBase

    swing_attr_accessor :enabled

    def initialize options = nil

      @component = JSlider.new unless options

      return unless options
      
      options[:orientation] = :horizontal unless options[:orientation]
      
      args = []
      args << map_orientation(options[:orientation])
      args << (options[:minimum] ? options[:minimum] : 0)
      args << (options[:maximum] ? options[:maximum] : 100)
      args << (options[:value] ? options[:value] : args[1])

      @component = JSlider.new(*args)
      
      @component.label_table = @component.createStandardLabels(10)
      @component.paint_labels = true
      
      self.name = options[:name].to_s if options[:name]
      self.enabled = options[:enabled] if options[:enabled]
      
      @style_id = self.name.to_sym if self.name
      @style_class = options[:style_class] if options[:style_class]

      options[:swing].call(java_component) if options[:swing]
      
    end

    def value= val
      @component.value = val
    end
    
    def apply_styles styles

      return unless styles
      
      if Defaults.enhanced_styling?
        font = styles.resolver.find_css_font(:button, @style_id, @style_class)
        @component.text = "#{font}#{@real_text}" if font
      else
        font = styles.resolver.find_font(:button, @style_id, @style_class)
        @component.font = font if font
      end
      
      color = styles.resolver.find_color(:button, @style_id, @style_class)
      @component.foreground = color if color
      
      color = styles.resolver.find_background_color(:button, @style_id, @style_class)
      if color
        @component.background = color
        @component.opaque = true
      end
      
      ticks = styles.resolver.find(:display_ticks, :button, @style_id, @style_class)
      @component.paint_labels = ticks unless ticks.nil?
      
    end
    
    private
    def map_orientation orientation
      if orientation == :vertical
        JSlider::VERTICAL
      else
        JSlider::HORIZONTAL
      end
    end
    
  end
  
end
