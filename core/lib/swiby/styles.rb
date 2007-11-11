#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby

  class Styles < Hash

    ARIAL       = "Arial"
    COURIER     = "Courier New"
    TIMES_ROMAN = "Times New Roman"
    VERDANA     = "Verdana"

    @@all_styles = Styles.new

    def self.styles &block

      if block.nil?
        @@all_styles
      else
        instance_eval(&block)
      end

    end

    def self.method_missing(meth, *args, &block)

      value = @@all_styles[meth]

      if value.nil?
        is_new = true
        value = Styles.new
      else
        is_new = false
      end

      if args.length > 0 and args[0].instance_of? Hash
        value.merge! args[0]
      elsif not block.nil?
        value.style_class = true
        value.instance_eval(&block)
      elsif is_new
        raise "Style property not found: #{meth}"
      end

      @@all_styles[meth] = value

    end

    def method_missing(meth, *args, &block)

      if self == @@all_styles
        Styles.method_missing meth
      else

        value = self[meth]

        if value.nil? and style_class?

          if args.length > 0 and args[0].instance_of? Hash

            value = Styles.new
            self[meth] = value

            value.merge! args[0]

          end

        end

        value

      end

    end

    def exist? style_class
      @@all_styles.has_key?(style_class)
    end

    def style_class= flag
      @is_style_class = flag
    end

    def style_class?
      @is_style_class
    end

  end

  def styles style_class = nil, &block

    if style_class.nil?

      Styles.styles &block

    else

      styles = Styles.styles[style_class]

      if styles.nil?
        raise "Style class not found: #{style_class}"
      end

      styles

    end

  end

end

