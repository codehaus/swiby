#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import javax.swing.JProgressBar

module Swiby
    
  module Builder
  
    def progress orientation = nil, min = nil, max = nil, name = nil, options = nil, &block

      ensure_section

      x = ProgressOptions.new(context, orientation, min, max, name, options, &block)
      
      but = Progress.new(x)

      context[x[:name].to_s] = but if x[:name]
      
      context.add_child but
      
      add but
      context << but
      
      layout_panel but
      
    end
  
  end

  class ProgressOptions < ComponentOptions
    
    define "Progress" do
      
      declare :minimum, [Fixnum], true
      declare :maximum, [Fixnum], true
      declare :value, [Fixnum], true
      declare :name, [String, Symbol], true
      declare :orientation, [Symbol], true
      declare :swing, [Proc], true
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      declare :style_class, [String, Symbol], true
      
      overload :orientation
      overload :orientation, :name
      overload :orientation, :maximum, :name
      overload :orientation, :minimum, :maximum
      overload :orientation, :minimum, :maximum, :name
      
    end
    
  end
  
  class Progress < SwingBase

    swing_attr_accessor :enabled

    def initialize options = nil
      
      @component = JProgressBar.new

      return unless options
      
      @component.setMaximum options[:maximum] if options[:maximum]
      @component.setMinimum options[:minimum] if options[:minimum]
      @component.setOrientation map_orientation(options[:orientation]) if options[:orientation]
      @component.setValue options[:value] if options[:value]
      
      self.name = options[:name].to_s if options[:name]
      self.enabled = options[:enabled] if options[:enabled]
      
      @style_id = self.name.to_sym if self.name
      @style_class = options[:style_class] if options[:style_class]

      options[:swing].call(java_component) if options[:swing]      
      
    end

    def value= x
      @component.setValue x
    end
    
    def value
      @component.getValue
    end
    
    # if text = :no_paint does not paint text anymore
    # if text = :default, paints the defailt display (percentage)
    def text= text
      
      if text == :default
        @component.string = nil
        @component.string_painted = true
      elsif text == :no_paint
        @component.string_painted = false
      else
        @component.string = text
        @component.string_painted = true
      end
    
    end
    
    def text
      @component.string
    end
    
    def apply_styles styles

      return unless styles
      
      font = styles.resolver.find_font(:progress_bar, @style_id, @style_class)
      @component.font = font if font
      
      color = styles.resolver.find_color(:progress_bar, @style_id, @style_class)
      @component.foreground = color if color
      
    end
    
    private
    def map_orientation orientation
      if orientation == :vertical
        JProgressBar::VERTICAL
      else
        JProgressBar::HORIZONTAL
      end
    end
    
  end
  
end