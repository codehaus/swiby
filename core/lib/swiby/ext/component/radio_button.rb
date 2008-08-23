#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require_extension :component, 'combo'
require_extension :component, 'panel'
require_extension :component, 'button'

module Swiby
  
  class RadioExtension < Extension
    include ComponentExtension
  end
  
  module Builder
  
    def radio text = nil, image = nil, options = nil, &block
      
      but = button_factory(text, image, options, block) do |opt|
        RadioButton.new(opt)
      end

      layout_list nil, but
      
    end
    
    def radio_group label = nil, values = nil, selected = nil, dir = nil, options = nil, &block
      
      args = [label, values, selected, dir, options, block, :layout_list]
            
      i = args.index(:horizontal)
      
      if i
        direction = :horizontal
        args.delete_at(i)
      end
      
      i = args.index(:vertical)
      
      if i
        direction = :vertical
        args.delete_at(i)
      end
      
      unless direction
        direction = :vertical
        args.delete_at(args.length - 3)
      end
      
      list_factory(*args) do |opt|
        RadioGroup.new(direction, opt)
      end
      
    end
 
  end

  class RadioButton < Button

    def create_button_component
      JRadioButton.new
    end
    
  end
  
  class RadioGroup < ComboBox
    
    def initialize dir = :vertical, options = nil
      
      @radio_items = []

      @panel = Panel.new
      
      if dir == :vertical
        layout = {:layout => :stacked, :align => :left}
      elsif dir == :horizontal
        layout = {:layout => :stacked, :align => :left, :direction => :horizontal}
      else
        options = dir
      end

      @panel.content(layout) {}
      
      super options
      
    end
    
    def create_list_component
      @panel.java_component
    end
    
    def selection=(index)
      @radio_items[index.to_i].selected = true
    end
    
    def item_count
      @radio_items.length
    end
    
    def add_item value
      
      @group = ButtonGroup.new unless @group
      
      radio = RadioButton.new(ButtonOptions.new(nil, value.to_s))
      
      @radio_items << radio
      
      @panel.add radio
      @group.add radio.java_component
      
    end
    
    def [] name
      
      if name.is_a?(Integer)
        return @radio_items[name]
      else
        
        @radio_items.each do |comp|
          return comp if (comp.name == name)
        end

      end
      
      nil
      
    end
    
    def action(&block)

      @radio_items.each_index do |i|
        
        listener = ActionListener.new

        @radio_items[i].java_component.addActionListener(listener)

        listener.register do
          block.call(@values[i])
        end

      end
      
    end
    
    def apply_styles styles
      
      return unless styles
      
      color = styles.resolver.find_color(:list, @style_id)
      bgcolor = styles.resolver.find_background_color(:list, @style_id)

      if Defaults.enhanced_styling?
        
        font = styles.resolver.find_css_font(:list, @style_id)
        
        @radio_items.each_index do |i|
          
          radio = @radio_items[i]
          value = @values[i]
          
          value = "#{font}#{value}" if font
          
          radio.java_component.text = value if font
          radio.java_component.foreground = color if color
          radio.java_component.background = bgcolor if bgcolor
          
        end
        
      else
        
        font = styles.resolver.find_font(:list, @style_id)
        
        @radio_items.each do |radio|
          radio.java_component.font = font if font
          radio.java_component.foreground = color if color
          radio.java_component.background = bgcolor if bgcolor
        end
        
      end
      
      @panel.java_component.background = bgcolor if bgcolor
        
    end
    
  end
  
end