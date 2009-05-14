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

  class AbsoluteFactory
    
    def accept name
      name == :absolute
    end
  
    def create name, data
      
      layout = AbsoluteLayout.new
      
      layout.hgap = data[:hgap] if data[:hgap]
      layout.vgap = data[:vgap] if data[:vgap]
      
      layout
      
    end
    
  end
  
  LayoutFactory.register_factory(AbsoluteFactory.new)
  
  class AbsoluteLayout
	
    include LayoutManager
    
    attr_accessor :hgap, :vgap
    
    def initialize hgap = 0, vgap = 0
      
      @hgap = hgap
      @vgap = vgap
      
      @components = []
      
    end

    def add_component_at comp, x, y
      @components << LayoutData.new(x, y, comp)
    end

    def add_component_relative comp, x, y, relative_to, h_relation, v_relation
      @components << LayoutData.new(x, y, comp, relative_to, h_relation, v_relation)
    end
    
    def add_layout_extensions component
      
        if component.respond_to?(:swiby_abs__actual_add)
          component.absolute_layout_manager = self
          return
        end

        class << component
          alias :swiby_abs__actual_add :add
        end
        
        def component.absolute_layout_manager= layout_mgr
          @layout_mgr = layout_mgr
        end
        
        component.absolute_layout_manager = self
        
        def component.add child
          
          swiby_abs__actual_add child
          
          return unless @pending_abs_position
          
          x, y = *@pending_abs_position
          
          if @pending_relative_data
            @layout_mgr.add_component_relative child, x, y, *@pending_relative_data
          else
            @layout_mgr.add_component_at child, x, y
          end
          
          @pending_abs_position = nil
          @pending_relative_data = nil
          
        end
        
        def component.at pos, relative_data = nil
          @pending_abs_position = pos
          @pending_relative_data = relative_data
        end

        def component.relative_to comp_name, h_relation, v_relation
          [self[comp_name], h_relation, v_relation]
        end
        
    end
    
    def minimumLayoutSize(parent)
      preferredLayoutSize parent
    end
    
    def preferredLayoutSize(parent)
      
      layoutContainer(parent)
      
      width = 10
      height = 10
      
      @components.each do |lay|
        
        bounds = lay.comp.bounds
        
        size = bounds.x + bounds.width
        width = width > size ? width : size
        
        size = bounds.y + bounds.height
        height = height > size ? height : size
        
      end
      
      Dimension.new(width + @hgap, height + @vgap)
      
    end
    
    def layoutContainer parent
    
      @components.each do |lay|
      
        next if lay.relative_to
        
        d = lay.comp.getPreferredSize()
        
        lay.comp.setBounds(lay.x + @hgap, lay.y + @vgap, d.width, d.height)
        
      end
      
      @components.each do |lay|
      
        if lay.relative_to
          
          d = lay.comp.getPreferredSize()
          relative = lay.relative_to.bounds
          
          x = y = 0
          
          case lay.v_relation
          when :align
            y = relative.y
          when :below
            y = relative.y + relative.height
          when :above
            y = relative.y - d.height
          when :center
            y = relative.y + (relative.height - d.height) / 2
          end
          
          case lay.h_relation
          when :align
            x = relative.x
          when :right
            x = relative.x + relative.width
          when :left
            x = relative.x - d.width
          when :center
            x = relative.x + (relative.width - d.width) / 2
          end
          
          lay.comp.setBounds(x + lay.x, y + lay.y, d.width, d.height)
          
        end
        
      end
      
    end
    
    class LayoutData
    
      attr_reader :x, :y, :comp, :relative_to, :h_relation, :v_relation
      
      def initialize x, y, comp, relative_to = nil, h_relation = nil, v_relation = nil
        
        @x = x
        @y = y
        @comp = comp.java_component
        
        @h_relation = h_relation
        @v_relation = v_relation
        @relative_to = relative_to.java_component if relative_to
        
      end
      
    end
    
    def addLayoutComponent(name, comp)
      raise NotImplementedError.new
    end
	
    def removeLayoutComponent(comp)
      raise NotImplementedError.new
    end
    
  end
  
end
