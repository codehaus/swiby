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
  
  class StackedExtension < Extension
    include LayoutExtension
  end

  class StackedFactory
  
    def accept name
      name == :stacked
    end
    
    def create name, data
          
      align = data[:align]
      direction = data[:direction]

      layout = StackedLayout.new

      layout.hgap = data[:hgap] if data[:hgap]
      layout.vgap = data[:vgap] if data[:vgap]

      layout.alignment = align if align
      layout.direction = direction if direction

      layout.sizing = data[:sizing] if data[:sizing]

      layout

    end
    
  end
  
  LayoutFactory.register_factory(StackedFactory.new)
  
end