require 'swiby'

module Swiby

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

      if text.instance_of? Hash
        options = text
        text = nil
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