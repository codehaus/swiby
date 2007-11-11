#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby'
require 'swiby/styles'

module Swiby

  class AccessorPath

    def initialize root_sym, sym = nil
      
      @path = [root_sym]
      
      @path << sym if sym
      
    end

    def to_s
      @path.join('.')
    end
    
    def / sym
      @path << sym
    end

    def resolve obj
    
      value = obj
      
      @path.each do |sym|
        value = value.send(sym)
      end
      
      value
      
    end
  
    def update obj, value
      
      unless @update_path
        
        @update_path = Array.new(@path)
        
        last = @update_path.pop
        
        @update_symbol = "#{last}=".to_sym
        
      end
      
      @update_path.each do |sym|
        obj = obj.send(sym)
      end
      
      obj.send(@update_symbol, value)
      
    end
    
  end

  module Builder

    def ensure_section
    end

    def layout_button button
    end

    def layout_label label
    end

    def layout_input label, text
    end

    def layout_list label, list
    end

    def layout_panel panel
    end

    def button text = nil, image = nil, options = nil, &block

      ensure_section

      x = ButtonOptions.new(context, text, image, options, &block)

      but = Button.new(x)

      context[x[:name].to_s] = but if x[:name]
      
      add but
      context << but
      layout_button but

    end

    def label text = nil, options = nil, &block

      ensure_section

      x = LabelOptions.new(context, text, options, &block)

      label = SimpleLabel.new(x)

      label.apply_styles
      
      context[x[:name].to_s] = label if x[:name]
      
      add label
      context << label
      layout_label label

    end

    def input label = nil, text = nil, options = nil, &block

      ensure_section

      x = InputOptions.new(context, label, text, options, &block)
      
      accessor = nil
      
      text = x[:text]
      
      if text.instance_of?(Symbol)
        accessor = AccessorPath.new(text)
        x[:name] = text.to_s
        x[:text] = @data.send(text)
      elsif text.instance_of?(AccessorPath)
        accessor = text
        x[:name] = text.to_s
        x[:text] = accessor.resolve(@data)
      end

      field = TextField.new(x)
      
      field.apply_styles

      if accessor
        
        add_updater do |restore|
          
          if restore
            field.value = accessor.resolve(@data)
          else
            accessor.update @data, field.value if field.editable?
          end
          
        end
        
      end
      
      if x[:label]
        label = SimpleLabel.new(x)
        label.apply_styles
        add label
        context << label
      end

      context[x[:name].to_s] = field if x[:name]
      
      add field
      context << field
      layout_input label, field

    end

    def combo label = nil, values = nil, selected = nil, options = nil, &block

      ensure_section

      x = ListOptions.new(context, label, values, selected, options, &block)
      
      accessor = nil
      
      selected = x[:selected]
      
      if selected.instance_of?(Symbol)
        accessor = AccessorPath.new(selected)
        x[:name] = selected.to_s
        x[:selected] = @data.send(selected)
      elsif selected.instance_of?(AccessorPath)
        accessor = selected
        x[:name] = selected.to_s
        x[:selected] = accessor.resolve(@data)
      end

      comp = ComboBox.new(x)

      if accessor
        
        add_updater do |restore|
          
          if restore
            comp.value = accessor.resolve(@data)
          else
            accessor.update @data, comp.value
          end
          
        end
        
      end

      if x[:label]
        label = SimpleLabel.new(x)
        label.apply_styles
        add label
        context << label
      end

      context[x[:name].to_s] = comp if x[:name]
      
      add comp
      context << comp
      layout_input label, comp

    end

    def list label = nil, values = nil, selected = nil, options = nil, &block

      ensure_section

      x = ListOptions.new(context, label, values, selected, options, &block)

      comp = ListBox.new(x)

      if x[:label]
        label = SimpleLabel.new(x)
        label.apply_styles
        add label
        context << label
      end

      context[x[:name].to_s] = comp if x[:name]
      
      add comp
      context << label
      layout_list label, comp

    end

    protected

    def add_updater &block
      
      @updaters = [] unless @updaters
      
      @updaters << block
      
    end
    
  end

end