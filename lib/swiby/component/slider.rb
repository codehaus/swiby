#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import javax.swing.JSlider

module Swiby
  
  module Builder
  
    def layout_button button
    end
    
    def slider text = nil, image = nil, options = nil, &block

      ensure_section

      x = SliderOptions.new(context, text, image, options, &block)
      
      but = Slider.new(x)

      context[x[:name].to_s] = but if x[:name]
      
      context.add_child but
      
      add but
      context << but
      
      layout_panel but
      
    end
  
  end
  
  class SliderOptions < ComponentOptions
    
    define "Slider" do
      
      declare :start, [Fixnum], true
      declare :end, [Fixnum], true
      declare :value, [Fixnum], true
      declare :name, [String, Symbol], true
      declare :orientation, [Symbol], true
      declare :swing, [Proc], true
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      
      overload :orientation, :name
      overload :orientation, :start, :name
      overload :orientation, :start, :end, :name
      overload :orientation, :start, :end, :value, :name
      
    end
    
  end

  class Slider < SwingBase

    swing_attr_accessor :enabled

    def initialize options = nil

      @component = JSlider.new unless options

      return unless options
      
      args = []
      args << map_orientation(options[:orientation]) if options[:orientation]
      args << options[:start] if options[:start]
      args << options[:end] if options[:end]
      args << options[:value] if options[:value]
      
      if options[:orientation] and (args.length != 1 or args.length != 4)
        raise "Must provide start and end values for slider" if options[:value] or args.length != 3
        args << options[:start]
      end

      @component = JSlider.new(*args)
      
      @component.label_table = @component.createStandardLabels(10)
      @component.paint_labels = true
      
      self.name = options[:name].to_s if options[:name]
      self.enabled = options[:enabled] if options[:enabled]
      
      @style_id = self.name.to_sym if self.name

      options[:swing].call(java_component) if options[:swing]
      
    end

    def apply_styles styles

      return unless styles
      
      if Defaults.enhanced_styling?
        font = styles.resolver.find_css_font(:button, @style_id)
        @component.text = "#{font}#{@real_text}" if font
      else
        font = styles.resolver.find_font(:button, @style_id)
        @component.font = font if font
      end
      
      color = styles.resolver.find_color(:button, @style_id)
      @component.foreground = color if color
      
      color = styles.resolver.find_background_color(:button, @style_id)
      if color
        @component.background = color
        @component.content_area_filled = false
        @component.opaque = true
      end
      
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
