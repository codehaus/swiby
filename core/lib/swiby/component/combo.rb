#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/label'

import javax.swing.JComboBox

module Swiby

  module Builder

    # in case <i>layout_input</i> is not defined in the calling context
    def layout_input label, text
    end
    
    def combo label = nil, values = nil, selected = nil, options = nil, &block
      list_factory(label, values, selected, options, block, :layout_input) do |opt|
        ComboBox.new(opt)
      end
    end

    # Needs a block that returns the Swiby wrapper
    def list_factory label, values, selected, options, block, layout_method

      ensure_section

      x = ListOptions.new(context, label, values, selected, options, &block)
      
      accessor = nil
      
      selected = x[:selected]
      
      if @data
        if selected.instance_of?(Symbol)
          accessor = AccessorPath.new(selected)
          x[:name] = selected.to_s
          x[:selected] = @data.send(selected)
        elsif selected.instance_of?(AccessorPath)
          accessor = selected
          x[:name] = selected.to_s
          x[:selected] = accessor.resolve(@data)
        end
      else
        x[:selected] = selected
      end
      

      comp = yield(x)

      if accessor
        
        add_updater do |restore|
          
          if restore
            comp.value = accessor.resolve(@data)
          else
            accessor.update @data, comp.value
          end
          
        end
        
      end

      label = nil
      
      if x[:label]
        x.delete(:action)
        label = SimpleLabel.new(x)
        add label
        context << label
        context.add_child label
      end

      context[x[:name].to_s] = comp if x[:name]
      
      context.add_child comp
        
      add comp
      context << comp
      
      self.send(layout_method, label, comp)
      
      comp

    end
    
  end
  
  class ListOptions < ComponentOptions
    
    define "List" do
      
      declare :name, [String, Symbol], true
      declare :label, [String, Symbol], true
      declare :values, [Array, AccessorPath]
      declare :selected, [Object], true
      declare :swing, [Proc], true
      declare :action, [Proc], true
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      declare :input_component, [Object], true
      declare :style_class, [String, Symbol], true
      
      overload :values
      overload :label, :values
      overload :label, :values, :selected
      
    end

  end

  class ComboBox < SwingBase

    attr_accessor :linked_label
    swing_attr_accessor :editable, :selection => :selected_index

    def initialize options = nil
      
      @component = create_list_component
      
      if @component.respond_to?(:set_renderer)
        renderer = create_renderer
        renderer.bind(self)
        @component.set_renderer renderer
      elsif @component.respond_to?(:set_cell_renderer)
        renderer = create_renderer
        renderer.bind(self)
        @component.set_cell_renderer renderer
      end
      
      return unless options
      
      options[:input_component] = self
      
      values = options[:values]
      selected = options[:selected]

      if values.instance_of? IncrementalValue
        values = values.get_value
      end
      
      @values = values
      
      fill_list

      self.value = selected

      self.name = options[:name].to_s if options[:name]
      
      @style_id = self.name.to_sym if self.name
      @style_class = options[:style_class] if options[:style_class]
      
      action(&options[:action]) if options[:action]
      
      options[:swing].call(java_component) if options[:swing]
      
      options[:swing] = nil
      
    end

    def editable?
      editable
    end
    
    def create_list_component
      JComboBox.new
    end
    
    def create_renderer
      Swing::SwibyComboBoxRender.new
    end

    def action(&block)

      listener = ActionListener.new

      @component.addActionListener(listener)

      listener.register do
        
        block.call(@values[@component.selected_index])
        
      end
      
    end
    
    def install_listener iv

      listener = ActionListener.new

      @component.addActionListener(listener)

      listener.register do
        iv.change @component.selected_index
      end

    end

    def selection=(index)
      @component.selected_index = index.to_i
    end
    
    def item_count
      @component.item_count
    end
    
    def clear
      @values = []
      @values_mapping.clear
      @component.removeAllItems
    end
    
    def content= values
      clear
      @values = values
      fill_list
    end
    
    def value= x

      select_index = 0

      @values.each do |value|

        self.selection = select_index if value == x

        select_index += 1
        
      end

    end
    
    def value
      
      index = selection
      
      @values[index] if index >= 0
      
    end
    
    def component_renderer
      @component.renderer
    end
    
    def apply_styles styles
      
      return unless styles
      
      if Defaults.enhanced_styling?
        
        renderer = component_renderer
        
        unless renderer.respond_to?(:swiby_real_get_component)
          
          class << renderer

            alias :swiby_real_get_component :getListCellRendererComponent

            def getListCellRendererComponent list, value, index, is_selected, cell_has_focus
              
              value = "#{@swiby_font}#{to_human_readable(value)}" if @swiby_font
              
              swiby_real_get_component list, value, index, is_selected, cell_has_focus
              
            end
            
            def swiby_set_enhanced_style font_style
              @swiby_font = font_style
            end

          end
          
        end
        
        font = styles.resolver.find_css_font(:list, @style_id, @style_class)
        renderer.swiby_set_enhanced_style(font) if font
       
      else
        font = styles.resolver.find_font(:list, @style_id, @style_class)
        @component.font = font if font
      end
      
      color = styles.resolver.find_color(:list, @style_id, @style_class)
      @component.foreground = color if color
      
      color = styles.resolver.find_background_color(:list, @style_id, @style_class)
      @component.background = color if color
      
      border = styles.resolver.create_border(:list, @style_id, @style_class)
        
      @component.border = border if border
      
    end
    
    #jRuby-behavior-001
    #TODO is it workaround?
    # necessary because when the value objects are added to JComboBox/JList,
    # they are wrapped by JRuby, but the renderer receives the wrapped object!
    def find_value hash
      @values_mapping[hash]
    end
    #jRuby-behavior-001 (end)
    
    protected
    
    def add_item value
      @component.add_item value
    end

    def fill_list

      @values_mapping = {} #jRuby-behavior-001
      
      @values.each do |value|
        self.add_item value
        @values_mapping[value.hash] = value #jRuby-behavior-001
      end
      
    end
    
  end
  
  module Swing
    
    include_class 'javax.swing.plaf.basic.BasicComboBoxRenderer'
    
    class SwibyComboBoxRender < BasicComboBoxRenderer
    
      def bind list_component
        @list_component = list_component
      end
      
      def getListCellRendererComponent list, value, index, is_selected, has_focus
        
        #jRuby-behavior-001
        if value.is_a?(::Java::OrgJruby::RubyObject)
          value = @list_component.find_value(value.hash)
        end
        #jRuby-behavior-001 (end)
        
        if value.respond_to?(:display_icon)
          set_icon value.display_icon
        end

        value = to_human_readable(value)

        super
        
      end
      
    end
    
  end
  
end