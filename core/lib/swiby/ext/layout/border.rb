#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout_factory'

module Swiby
  
  class BorderExtension < Extension
    include LayoutExtension
  end

  class BorderFactory
  
    def accept name
      name == :border
    end
    
    def create name, data
          
      layout = AWT::BorderLayout.new

      layout.hgap = data[:hgap] if data[:hgap]
      layout.vgap = data[:vgap] if data[:vgap]
          
      def layout.add_layout_extensions component

        return if component.respond_to?(:swiby_border__actual_add)

        class << component
          alias :swiby_border__actual_add :add
        end

        def component.add x

          if @position
            swiby_border__actual_add x, @position
          else
            swiby_border__actual_add x
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
                
    end
    
  end
  
  LayoutFactory.register_factory(BorderFactory.new)
  
end