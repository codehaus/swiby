#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/swing/layout'

module Swiby
    
  FLOW_ALIGNMENTS = {
    :left => AWT::FlowLayout::LEFT, 
    :center => AWT::FlowLayout::CENTER, 
    :right => AWT::FlowLayout::RIGHT
  }

  def create_layout *options
      
      if options.length == 1 and options[0].respond_to?(:[])
        
        data = options[0]
        
        lm = data[:layout]
        
        case lm 
        when :default
        when :flow
          
          align = FLOW_ALIGNMENTS[data[:align]]
          
          layout = AWT::FlowLayout.new
          
          layout.hgap = data[:hgap] if data[:hgap]
          layout.vgap = data[:vgap] if data[:vgap]
          
          layout.alignment = align if align
          
          layout
          
        when :stacked
          
          align = data[:align]
          direction = data[:direction]
          
          layout = StackedLayout.new
          
          layout.hgap = data[:hgap] if data[:hgap]
          layout.vgap = data[:vgap] if data[:vgap]
          
          layout.alignment = align if align
          layout.direction = direction if direction
          
          layout.sizing = data[:sizing] if data[:sizing]
          
          layout
          
        when :border
          
          layout = AWT::BorderLayout.new
          
          layout.hgap = data[:hgap] if data[:hgap]
          layout.vgap = data[:vgap] if data[:vgap]
          
          def layout.add_layout_extensions component
            
            return if component.respond_to?(:swiby__actual_add)
            
            class << component
              alias :swiby__actual_add :add
            end
            
            def component.add x
              
              if @position
                swiby__actual_add x, @position
              else
                swiby__actual_add x
              end
              
            end
            
            def component.north
              @position = AWT::BorderLayout::NORTH
            end
            
            def component.east
              @position = AWT::BorderLayout::EAST
            end
            
            def component.center
              @position = AWT::BorderLayout::CENTER              
            end
            
            def component.south
              @position = AWT::BorderLayout::SOUTH              
            end
            
            def component.west
              @position = AWT::BorderLayout::WEST
            end
            
          end
          
          layout
          
        when :area
          
          AreaLayout.new
          
        else
          #TODO report error?
        end
        
      elsif options.length > 0
        raise ArgumentError, 'Expect Hash with layout options'
      end
    
  end
  
end
