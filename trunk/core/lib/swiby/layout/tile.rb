#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout_factory'

import java.awt.Dimension
import java.awt.LayoutManager

module Swiby

  class TileFactory
    
    def accept name
      name == :tile
    end
  
    def create name, data
      
      layout = TileLayout.new
      
      layout.hgap = data[:hgap] if data[:hgap]
      layout.vgap = data[:vgap] if data[:vgap]
      
      layout
      
    end
    
  end
  
  LayoutFactory.register_factory(TileFactory.new)
  
  #TODO add left_right / top_bottom options + v_align and h_align options for children components: left/center/right and top/center/bottom
  class TileLayout
	
    include LayoutManager
    
    attr_accessor :hgap, :vgap
    
    def initialize hgap = 0, vgap = 0
      
      @hgap = hgap
      @vgap = vgap
      
    end

    def minimumLayoutSize(parent)
      preferredLayoutSize parent
    end
    
    def preferredLayoutSize(parent)
      
      layoutContainer(parent)
      
      width = 10
      height = 10
      
      parent.components.each do |comp|
        
        bounds = comp.bounds
        
        size = bounds.x + bounds.width
        width = width > size ? width : size
        
        size = bounds.y + bounds.height
        height = height > size ? height : size
        
      end
      
      Dimension.new(width + @hgap, height + @vgap)
      
    end
    
    def layoutContainer parent
    
      components = parent.components
      
      return if components.length == 0
      
      width = parent.width
      height = parent.height
      
      max_comp_width = 0
      max_comp_height = 0
      
      components.each do |comp|
      
        next unless comp.visible?
        
        d = comp.get_preferred_size
        
        max_comp_width = max_comp_width > d.width ? max_comp_width : d.width 
        max_comp_height = max_comp_height > d.height ? max_comp_height : d.height
        
      end
      
      x = @hgap
      y = @vgap
      
      components.each do |comp|
      
        next unless comp.visible?
        
        d = comp.get_preferred_size
        
        comp.set_bounds(x, y, d.width, d.height)
        
        x += max_comp_width + @hgap
        
        if x + max_comp_width + @hgap > width
          x = @hgap
          y += max_comp_height + @vgap
        end
        
      end
      
    end
    
    def addLayoutComponent(name, comp)
    end
	
    def removeLayoutComponent(comp)
    end
    
  end
  
end
