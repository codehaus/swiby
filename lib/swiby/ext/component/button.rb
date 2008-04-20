#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby
  
  class ButtonExtension < Extension
    include ComponentExtension
  end
  
  module Builder
  
    def layout_button button
    end
    
    def button text = nil, image = nil, options = nil, &block
      button_factory(text, image, options, block) do |opt|
        Button.new(opt)
      end
    end
    
    # Needs a block that returns the Swiby component
    def button_factory text, image, options, block

      ensure_section

      x = ButtonOptions.new(context, text, image, options, &block)

      but = yield(x)

      context[x[:name].to_s] = but if x[:name]
      
      context.add_child but
      
      add but
      context << but
      layout_button but

    end
  
  end
  
  class ButtonOptions < ComponentOptions
    
    define "Button" do
      
      declare :name, [String, Symbol], true
      declare :text, [String, Symbol], true
      declare :icon, [ImageIcon, String], true
      declare :action, [Proc], true
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      
      overload :text
      overload :icon
      overload :text, :name
      overload :text, :icon
      overload :text, :icon, :enabled
      
    end
    
  end

  class Button < SwingBase

    swing_attr_accessor :enabled, :editable, :selected

    def initialize options = nil

      @component = create_button_component

      return unless options

      self.text = options[:text] if options[:text]
      self.enabled_state = options[:enabled] unless options[:enabled].nil?
      self.name = options[:name].to_s if options[:name]
      
      @style_id = self.name.to_sym if self.name

      icon options[:icon] if options[:icon]
      action(&options[:action]) if options[:action]

    end
    
    def create_button_component
      JButton.new
    end

    def editable?
      editable
    end
    
    def selected?
      selected
    end

    def enabled_state= value

      if value.instance_of? IncrementalValue
        value.assign_to self, :enabled=
      else
        self.enabled = value
      end

    end

    def text=(t)
      @real_text = t
      @component.text = t      
    end

    def text
      @real_text
    end

    def icon(image)

      if not image.nil? and image.instance_of?(String)
        image = Swiby::create_icon(image)
      end

      @component.icon = image unless image.nil?

    end

    def mnemonic(char)
      @component.mnemonic = char[0]
    end

    def tooltip(text)
      @component.toolTipText = text
    end

    def action(&block)

      listener = ActionListener.new

      @component.addActionListener(listener)

      listener.register(&block)

    end

    def verticalTextPosition pos
      @component.verticalTextPosition = pos
    end

    def horizontalTextPosition pos
      @component.horizontalTextPosition = pos
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
    
  end
  
end