#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import javax.swing.JTextField
import javax.swing.JFormattedTextField
import javax.swing.text.MaskFormatter
import javax.swing.text.DefaultFormatterFactory

require 'swiby/data/converter/date_converter'

require 'swiby/component/label'
require 'swiby/component/shortcut'

module Swiby
    
  module Builder

    def layout_input label, text
    end

    # Creates a input field without label
    def text text = nil, options = nil, &block
      text_input_factory TextOptions.new(context,text, options, block) do |opt|
        TextField.new(opt)
      end
    end
    
    # Creates a input field without label for date values
    def date text = nil, options = nil, &block
      text_input_factory TextOptions.new(context,text, options, block), :date do |opt|
        TextField.new(opt)
      end
    end		
		
    # Creates an input field with label for date values
    def input_date label = nil, text = nil, options = nil, &block
      text_input_factory InputOptions.new(context, label, text, options, &block), :date do |opt|
        TextField.new(opt)
      end
		end
		
    # Creates an input field with label for free string values
    def input label = nil, text = nil, options = nil, &block
      text_input_factory InputOptions.new(context, label, text, options, &block) do |opt|
        TextField.new(opt)
      end
    end
    
    # Creates an input field with label for password values
    def password label = nil, text = nil, options = nil, &block
      text_input_factory InputOptions.new(context, label, text, options, &block) do |opt|
        PasswordField.new(opt)
      end
    end
    
    # Creates the visual component(s)
    # Needs a block that returns the Swiby wrapper
    #
    # +options+ is a ComponentOptions for inputs
    # +type+ (optional) is the type of data to input
    def text_input_factory options, type = nil

      ensure_section

      accessor = nil
      
      options[:type] = type if type
      
      text = options[:text]
      
      if text.instance_of?(Symbol)
        accessor = AccessorPath.new(text)
        options[:name] = text.to_s
        options[:text] = @data.send(text)
      elsif text.instance_of?(AccessorPath)
        accessor = text
        options[:name] = text.to_s
        options[:text] = accessor.resolve(@data)
      end

      field = yield(options)
      
      if accessor
        
        add_updater do |restore|
          
          if restore
            field.value = accessor.resolve(@data)
          else
            accessor.update @data, field.value if field.editable?
          end
          
        end
        
      end
      
      label = nil
      
      if options[:label]
        options.delete(:action)
        label = SimpleLabel.new(options)
        add label
        context << label
        context.add_child label
      end

      context[options[:name].to_s] = field if options[:name]
      
      context.add_child field
      
      add field
      context << field
      layout_input label, field

    end
    
  end
  
  class InputOptions < ComponentOptions
    
    define "Input" do
      
      declare :name, [String, Symbol], true
      declare :label, [String, Symbol], true
      declare :text, [Object]
      declare :type, Symbol, true # defaults to free string input
      declare :columns, [Integer], true
      declare :swing, [Proc], true
      declare :on_key, [KeyHandler], true
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      declare :readonly, [TrueClass, FalseClass, IncrementalValue], true
      declare :input_component, [Object], true
      
      overload :text
      overload :label, :text
      
    end
    
  end
  
  class TextOptions < ComponentOptions
    
    define "Text" do
      
      declare :name, [String, Symbol], true
      declare :text, [Object], true
      declare :type, Symbol, true # defaults to free string input
      declare :columns, [Integer], true
      declare :swing, [Proc], true
      declare :on_key, [KeyHandler], true
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      declare :readonly, [TrueClass, FalseClass, IncrementalValue], true
      declare :input_component, [Object], true
      
      overload :text
      
    end
    
  end

  class TextField < SwingBase

    DATA_CONVERTERS = {:default => nil, :date => DateConverter.new}
    ALIGNMENT_TYPES = {:left => JTextField::LEFT, :center => JTextField::CENTER, :right => JTextField::RIGHT}
    
    attr_accessor :linked_label
    swing_attr_accessor :columns, :editable

    def initialize options = nil
      
      @component = JFormattedTextField.new
      
      @component.focus_lost_behavior = JFormattedTextField::COMMIT
      
      return unless options
      
      options[:input_component] = self
      
      x = options[:text]
      
      if options[:on_key]
        on_keyboard options[:on_key]
      end
      
      if x.instance_of? IncrementalValue
        x.assign_to self, :value=
      else
        self.value = x if x and not (x.is_a?(String) and x.length == 0)
      end
      
      self.name = options[:name].to_s if options[:name]
      self.editable = !options[:readonly] if options[:readonly]
      
      @style_id = self.name.to_sym if self.name      
      @style_class = options[:style_class] if options[:style_class]
      @component.columns = options[:columns] if options[:columns]
      
      @converter = DATA_CONVERTERS[options[:type]] if options[:type]
      
      options[:swing].call(java_component) if options[:swing]
      
      options[:swing] = nil
      
    end

    def apply_styles styles
      
      return unless styles
      
      font = styles.resolver.find_font(:input, @style_id, @style_class)
      @component.font = font if font
      
      color = styles.resolver.find_color(:input, @style_id, @style_class)
      @component.foreground = color if color
      
      color = styles.resolver.find_background_color(:input, @style_id, @style_class)
      @component.background = color if color
      
      align = styles.resolver.find(:text_align, :input, @style_id, @style_class)
      @component.horizontal_alignment = ALIGNMENT_TYPES[align] if align and ALIGNMENT_TYPES[align]
      
      readonly = styles.resolver.find(:readonly, :input, @style_id, @style_class)
      @component.editable = !readonly unless readonly.nil?
      
    end

    def editable?
      editable
    end
    
    def on_keyboard key_handler
      
      listener = KeyListener.new
      
      listener.register key_handler
      
      java_component.addKeyListener listener
      
    end
    
    def on_change &block
            
      listener = PropertyChangeListener.new

      listener.register(&block)

      @component.addPropertyChangeListener('value', listener)
  
    end
    
    def value
      
      begin
        @component.commitEdit
      rescue
        return nil
      end
      
      x = @component.text unless @converter
      x = @converter.ui_value_to_internal(@component.value) if @converter
      x
      
    end

    def value=(val)

      val = @converter.internal_value_to_ui(val) if @converter
      
      plugged_formatter = plug_formatter_for(val)
      
      @component.value = val.nil? ? '' : val
      @component.getFormatter.setOverwriteMode(false) unless plugged_formatter
       
    end
    
    def plug_formatter_for value

      if @converter
        @converter.plug_input_formatter self
        true
      else
        false
      end
      
    end

    def input_mask mask, placeholder = "_"
      
      formatter = MaskFormatter.new

      formatter.mask = mask

      formatter.placeholder_character = placeholder[0]
      formatter.value_contains_literal_characters = false

      self.formatter_factory = DefaultFormatterFactory.new(formatter)

    end
    
    def date mask = nil

      return unless mask
      
      fmt = DateFormatter.new(SimpleDateFormat.new(mask))

      self.formatter_factory = DefaultFormatterFactory.new(fmt)

    end
    
    def currency cur
      
      #TODO add support for country as string or symbol
      case cur
      when :euro
        locale = Locale::FRANCE
      when :dollar
        locale = Locale::US
      end

      fmt = NumberFormat::getCurrencyInstance(locale)

      self.formatter_factory = DefaultFormatterFactory.new(NumberFormatter.new(fmt))

      @component.horizontal_alignment = JTextField::RIGHT
        
    end
    
    def formatter_factory= factory
      @component.formatter_factory = factory
    end

  end
  
  class PasswordField < SwingBase
    
    attr_accessor :linked_label

    def initialize options = nil
      
      @component = javax.swing.JPasswordField.new
      
      return unless options
      
      options[:input_component] = self
      
      x = options[:text]
      
      if x.instance_of? IncrementalValue
        x.assign_to self, :value=
      else
        self.value = x if x
      end
      
      self.name = options[:name].to_s if options[:name]
      
      @component.columns = options[:columns] if options[:columns]
      
      options[:swing].call(java_component) if options[:swing]
      
      options[:swing] = nil
      
    end

    def apply_styles styles
    end

    def on_change &block
            
      listener = PropertyChangeListener.new

      listener.register(&block)

      @component.addPropertyChangeListener('value', listener)
  
    end
    
    def value
      @component.text
    end

    def value=(val)
      @component.text = val
    end
    
  end
  
end