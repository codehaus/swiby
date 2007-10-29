require 'swiby'

module Swiby

  class AccessorPath

    def initialize root_sym, sym = nil
      
      @path = [root_sym]
      
      @path << sym if sym
      
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

    def layout_button comp
    end

    def layout_input label, text
    end

    def layout_list label, list
    end

    def button text = nil, image = nil, options = nil, &block

      ensure_section

      block_options = nil

      if image.instance_of? Hash
        options = image
        image = nil
      elsif image == :more_options
        block_options = block
        block = nil
        image = nil
      end

      if text.instance_of? Hash
        options = text
        text = nil?
      elsif text.instance_of? ImageIcon
        image = text
        text = nil
      elsif text == :more_options
        block_options = block
        block = nil
        text = nil
      end

      if text.nil? and image.nil? and options.nil?
        block_options = block
        block = nil
      end

      options = {} unless options

      options[:text] = text if text
      options[:icon] = image if image
      options[:action] = block if block

      x = ButtonOptions.new

      local_context = context #TODO pattern repeated at several places!

      x.instance_eval do

        @local_context = local_context

        def context()
          @local_context
        end

      end

      x << options

      x.instance_eval(&block_options) if block_options

      but = Button.new(x)

      add but
      layout_button but

    end

    def input label = nil, text = nil, &block_options

      ensure_section

      options = nil

      if text.nil? and !label.nil?
        text = label
        label = nil
      end

      accessor = nil
      
      if text.instance_of? Hash
        options = text
        text = nil
      elsif text.instance_of?(Symbol)
        accessor = AccessorPath.new(text)
        text = @data.send(text)
      elsif text.instance_of?(AccessorPath)
        accessor = text
        text = accessor.resolve(@data)
      end

      options = {} unless options

      options[:text] = text if text
      options[:label] = label if label

      x = InputOptions.new

      local_context = context #TODO pattern repeated at several places!

      x.instance_eval do

        @local_context = local_context

        def context()
          @local_context
        end

      end

      x << options

      x.instance_eval(&block_options) if block_options

      field = TextField.new(x)

      if accessor
        
        add_updater do |restore|
          
          if restore
            field.value = accessor.resolve(@data)
          else
            accessor.update @data, field.value
          end
          
        end
        
      end
      
      if x[:label]
        label = SimpleLabel.new(x)
        add label
      end

      add field
      layout_input label, field

    end

    def combo label = nil, values = nil, selected = nil, &block

      ensure_section

      x = create_list_like_options(label, values, selected, &block)

      comp = ComboBox.new(x)

      if x[:label]
        label = SimpleLabel.new(x)
        add label
      end

      add comp
      layout_input label, comp

    end

    def list label = nil, values = nil, selected = nil, &block

      ensure_section

      x = create_list_like_options(label, values, selected, &block)

      comp = ListBox.new(x)

      if x[:label]
        label = SimpleLabel.new(x)
        add label
      end

      add comp
      layout_list label, comp

    end

    protected

    def add_updater &block
      
      @updaters = [] unless @updaters
      
      @updaters << block
      
    end
    
    def create_list_like_options label = nil, values = nil, selected = nil, &block

      options = nil
      block_options = nil

      if label.instance_of? Hash
        options = label
        label = nil
      elsif values.nil? and label.nil? and selected.nil?

        if block.nil?
          values = []
        else
          block_options = block
          block = nil
        end

      elsif values.nil?

        if label.respond_to?(:each)
          values = label
          label = nil
        else
          values = []
        end

      elsif values.instance_of?(Symbol)
        values = @data.send(values)
      elsif values.instance_of?(AccessorPath)
        values = values.resolve(@data)
      end

      options = {} unless options

      options[:label] = label if label
      options[:values] = values if values
      options[:selected] = selected if selected
      options[:action] = block if block

      x = ListOptions.new

      local_context = context #TODO pattern repeated at several places!

      x.instance_eval do

        @local_context = local_context

        def context()
          @local_context
        end

      end

      x << options

      x.instance_eval(&block_options) if block_options

      x

    end

  end

end