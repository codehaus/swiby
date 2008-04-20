#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'irb/frame'

module Swiby

  class Styles

    ARIAL       = "Arial"
    COURIER     = "Courier New"
    TIMES_ROMAN = "Times New Roman"
    VERDANA     = "Verdana"
    
  end
  
  class StylesDefinition

    def initialize
      @data = {}
    end
   
    def self.styles &block
     
      return nil if block.nil?
     
      s = StylesDefinition.new
      s.instance_eval(&block)
      s
     
    end

    def resolver
      @resolver = StyleResolver.new(self) unless @resolver
      @resolver
    end
    
    def has_class? style_class
      @data.has_key?(style_class) and @data[style_class].is_a?(StyleClass)
    end

    def has_element? element
      @data.has_key?(element) and @data[element].is_a?(Styles)
    end
    
    def merge! &block
      instance_eval(&block)
      self
    end
   
    def data
      @data
    end

    def[] key
     
      styles = @data[key]
     
      if styles.nil?
        raise(ArgumentError, "Style class or style element not found: #{key}")
      end
     
      styles
     
    end
    
    def method_missing(meth, *args, &block)

      if @data.has_key?(meth)
        
        if @data[meth].is_a?(StyleClass) and block
          @data[meth].merge!(&block)
        elsif args.length == 1 and args[0].is_a?(Hash)
          @data[meth].merge! args[0]
        else
          @data[meth]
        end
        
      else

        if args.length == 0
          
          raise(ArgumentError, "Style class or style element not found: #{meth}") unless block
          
          value = StyleClass.new
          value.instance_eval(&block)
          
          @data[meth] = value
          
          return value
          
        end

        if args.length > 1 or not args[0].is_a?(Hash)
          raise(ArgumentError, "Expected 1 Hash argument near '#{meth}'")
        end
        
        value = Styles.new
        value.data.merge! args[0]

        @data[meth] = value
       
      end

    end
   
    private
    
    class StyleClass
      
      def initialize
        @data = {}
      end

      def resolver
        @resolver = StyleResolver.new(self) unless @resolver
        @resolver
      end
   
      def data
        @data
      end

      def has_element? element
        @data.has_key?(element) and @data[element].is_a?(Styles)
      end

      def[] key

        styles = @data[key]

        if styles.nil?
          raise "Style element not found: #{key}"
        end

        styles

      end
    
      def merge! &block
        instance_eval(&block)
        self
      end

      def method_missing(meth, *args, &block)

        if @data.has_key?(meth)

          if args.length == 1 and args[0].is_a?(Hash)
            @data[meth].merge! args[0]
          else
            @data[meth]
          end
          
        else

          raise(ArgumentError, "Expected 1 Hash argument near '#{meth}'") if args.length == 0

          if args.length > 1 or not args[0].is_a?(Hash)
            raise(ArgumentError, "Expected 1 Hash argument near '#{meth}'")
          end

          value = Styles.new
          value.data.merge! args[0]

          @data[meth] = value

        end
        
      end
      
    end
    
    class Styles
      
      def initialize
        @data = {}
      end
   
      def data
        @data
      end

      def merge! properties
        @data.merge! properties
        self
      end

      def[] key

        styles = @data[key]

        if styles.nil?
          raise "Style property not found: #{key}"
        end

        styles

      end

      def method_missing(meth, *args, &block)
        @data[meth]
      end
      
    end
    
  end

  def create_styles &block
    StylesDefinition.styles(&block)
  end

  def load_styles file
    
    if file.is_a?(String)
      
      path = resolve_file(file)
      path = resolve_local_file(file) unless path
      
      unless path        
          
        b = IRB::Frame.top(1)
        
        dir = File.dirname(eval("__FILE__", b))
        path = File.expand_path(file, dir)
        
      end

      raise(LoadError, "Cannot load style file: #{file}") unless path and File.exist?(path)
      
      file = File.new(path)
      
    end
    
    script = file.read
    
    eval(script)
    
  end

end
