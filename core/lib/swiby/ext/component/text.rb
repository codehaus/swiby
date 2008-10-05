#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require_extension :component, 'label'
require_extension :component, 'shortcut'

module Swiby
    
  class TextExtension < Extension
    include ComponentExtension
  end

  module Builder

    def layout_input label, text
    end

    def input label = nil, text = nil, options = nil, &block
      text_input_factory label, text, options, block do |opt|
        TextField.new(opt)
      end
    end
    
    def password label = nil, text = nil, options = nil, &block
      text_input_factory label, text, options, block do |opt|
        PasswordField.new(opt)
      end
    end
    
    # Needs a block that returns the Swiby wrapper
    def text_input_factory label, text, options, block

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

      field = yield(x)
      
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
      
      if x[:label]
        x.delete(:action)
        label = SimpleLabel.new(x)
        add label
        context << label
        context.add_child label
      end

      context[x[:name].to_s] = field if x[:name]
      
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

  class TextField < SwingBase

    attr_accessor :linked_label
    swing_attr_accessor :columns, :editable

    def initialize options = nil
      
      @component = JFormattedTextField.new
      
      return unless options
      
      options[:input_component] = self
      
      x = options[:text]
      
      if options[:on_key]
        on_keyboard options[:on_key]
      end
      
      if x.instance_of? IncrementalValue
        x.assign_to self, :value=
      else
        self.value = x if x
      end
      
      self.name = options[:name].to_s if options[:name]
      self.editable = !options[:readonly] if options[:readonly]
      
      @style_id = self.name.to_sym if self.name      
      @component.columns = options[:columns] if options[:columns]
      
      options[:swing].call(java_component) if options[:swing]
      
      options[:swing] = nil
      
    end

    def apply_styles styles
      
      return unless styles
      
      font = styles.resolver.find_font(:input, @style_id)
      @component.font = font if font
      
      color = styles.resolver.find_color(:input, @style_id)
      @component.foreground = color if color
      
      color = styles.resolver.find_background_color(:input, @style_id)
      @component.background = color if color
      
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
      @component.value
    end

    def value=(val)
      
      plug_formatter_for val unless @formatter_set
      
      @component.value = val
      
    end
    
    def plug_formatter_for value

      if value.respond_to?(:plug_input_formatter)
        value.plug_input_formatter self
      end
      
      @formatter_set = true
      
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