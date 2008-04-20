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

    def use_styles styles = nil, &block
      
      case styles
      when NilClass
        @styles = nil unless block
        @styles = create_styles(&block) if block
      when StylesDefinition
        @styles = styles
      when String, File
        @styles = load_styles(styles)
      end
      
    end

    protected

    def add_updater &block
      
      @updaters = [] unless @updaters
      
      @updaters << block
      
    end

    def set_context block
      
      the_form = self
      
      block.instance_eval do
        
          @the_form = the_form
          
          def block.context
            @the_form
          end
  
      end
      
    end
    
  end

end