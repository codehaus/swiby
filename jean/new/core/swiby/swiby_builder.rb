require 'swiby'

module Swiby

  module Builder

    def button text = nil, image = nil, options = nil, &block

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

      local_context = context

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

    end

  end

end