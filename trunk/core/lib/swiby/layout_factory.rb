#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/swing/layout'

import java.awt.FlowLayout

module Swiby
    
  class LayoutFactory
  
    @@factories = []
    
    def self.register_factory factory
      @@factories << factory
    end
    
    def self.create_layout name, options
    
      @@factories.each do |factory|
        if factory.accept(name)
          return factory.create(name, options)
        end
      end
      
      raise "Unresolved layout manager: #{name}"
      
    end
    
  end
  
  FLOW_ALIGNMENTS = {
    :left => FlowLayout::LEFT, 
    :center => FlowLayout::CENTER, 
    :right => FlowLayout::RIGHT
  }

  def create_layout *options
      
      if options.length == 1 and options[0].respond_to?(:[])
        
        data = options[0]
        
        lm = data[:layout]
        
        case lm 
        when :default
        when :flow
          
          align = FLOW_ALIGNMENTS[data[:align]]
          
          layout = FlowLayout.new
          
          layout.hgap = data[:hgap] if data[:hgap]
          layout.vgap = data[:vgap] if data[:vgap]
          
          layout.alignment = align if align
          
          layout
          
        else
          LayoutFactory.create_layout(lm, data)
        end
        
      elsif options.length > 0
        raise ArgumentError, 'Expect Hash with layout options'
      end
    
  end
  
end
