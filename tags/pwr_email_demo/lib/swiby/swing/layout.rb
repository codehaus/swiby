#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'java'

import java.awt.Dimension
import java.awt.LayoutManager

require 'miglayout-3.6.3-swing.jar'

import 'net.miginfocom.swing.MigLayout'

module Swiby

  def full_insets(parent)
	
    insets = parent.insets
			
    if !parent.border.nil?
	
      border = parent.border.getBorderInsets(parent)
		
      insets.top += border.top
      insets.left += border.left
      insets.right += border.right
      insets.bottom += border.bottom
		
    end
	
    insets
	
  end

  class StackedLayout
	
    include LayoutManager
    
    attr_accessor :change_layout
    attr_accessor :hgap, :vgap, :direction, :alignment, :sizing
    
    def initialize(hgap = 0, vgap = 0, direction = :vertical, align = :center, sizing = :normal)
		
      @hgap = hgap
      @vgap = vgap
      @sizing = sizing
      @alignment = align
      @direction = direction
      
      @change_layout = []
      
    end
	
    def add_layout_extensions component
      
      def component.stacked_layout_manager= lm
        @stacked_layout_manager = lm
      end
      
      def component.align *x
        @stacked_layout_manager.change_layout.push [self.java_container.component_count] + x
      end

      def component.bottom
        @stacked_layout_manager.change_layout.push [self.java_container.component_count] + [:bottom]
      end
      
      component.stacked_layout_manager = self
      
    end
    
    def addLayoutComponent(name, comp)
      raise NotImplementedError.new
    end
	
    def removeLayoutComponent(comp)
      raise NotImplementedError.new
    end
	
    def preferredLayoutSize(parent)
      minimumLayoutSize parent
    end
    
    def minimumLayoutSize(parent)
       
      if @direction == :horizontal
        minimumHorizontal parent
      else
        minimumVertical parent
      end
      
    end
    
    def layoutContainer parent

      if @direction == :horizontal
        layoutHorizontal parent
      else
        layoutVertical parent
      end

    end
    
    private 
    
    def layoutVertical parent
       
      x = @hgap
      y = @vgap

      width = parent.width - 2 * @hgap
      
      if @sizing == :maximum
        
        max_width = 0
        
        for comp in parent.getComponents()

          dim = comp.getPreferredSize()
          
          max_width = dim.width if max_width < dim.width
          
        end
        
      end

      bottom_index = nil
      component_index = 0
      layout_change_index = 0
      
      alignment = @alignment
      
      for comp in parent.getComponents()

        if layout_change_index < @change_layout.length
          
          while layout_change_index < @change_layout.length and 
              @change_layout[layout_change_index][0] == component_index
            
            if @change_layout[layout_change_index][1] == :bottom
              bottom_index = component_index
            else
              alignment = @change_layout[layout_change_index][1]
            end
            
             layout_change_index += 1
              
          end
          
        end
        
        dim = comp.getPreferredSize()

        dim.width = max_width if max_width
        
        if alignment == :center
          x = @hgap + (width - dim.width) / 2
        elsif alignment == :right
          x = @hgap + width - dim.width
        else
          x = @hgap
        end

        comp.setBounds(x, y, dim.width, dim.height)

        y += dim.height + @vgap
        
        component_index += 1

      end
      
      if bottom_index
        
        offset = parent.height - y
        
        if offset > 0
          
          kids = parent.getComponents()

          while bottom_index < component_index
            p = kids[bottom_index].getLocation
            kids[bottom_index].setLocation(p.x, p.y + offset)
            bottom_index += 1
          end
          
        end
        
      end
       
    end

    def layoutHorizontal parent
       
      x = @hgap
      y = @vgap

      height = parent.height - 2 * @vgap
      
      if @sizing == :maximum
        
        max_height = 0
        
        for comp in parent.getComponents()

          dim = comp.getPreferredSize()
          
          max_height = dim.height if max_height < dim.height
          
        end
        
      end

      bottom_index = nil
      component_index = 0
      layout_change_index = 0
      
      alignment = @alignment

      for comp in parent.getComponents()

        if layout_change_index < @change_layout.length
          
          if @change_layout[layout_change_index][0] == component_index
            
            if @change_layout[layout_change_index][1] == :bottom
              bottom_index = component_index
            else
              alignment = @change_layout[layout_change_index][1]
            end
            
             layout_change_index += 1
              
          end
          
        end

        dim = comp.getPreferredSize()

        dim.height = max_height if max_height

        if @alignment == :center
          y = @vgap + (height - dim.height) / 2
        elsif @alignment == :right
          y = @vgap + height - dim.height
        else
          y = @vgap
        end

        comp.setBounds(x, y, dim.width, dim.height)

        x += dim.width + @hgap
        
        component_index += 1

      end
      
      if bottom_index
        
        offset = parent.width - x
        
        if offset > 0
          
          kids = parent.getComponents()

          while bottom_index < component_index
            p = kids[bottom_index].getLocation
            kids[bottom_index].setLocation(p.x + offset, p.y)
            bottom_index += 1
          end
          
        end
        
      end
       
    end
   
    def minimumVertical parent

      height = @vgap
      maxWidth = 0

      for comp in parent.getComponents()

        dim = comp.getPreferredSize()

        maxWidth = maxWidth < dim.width ? dim.width : maxWidth

        height += dim.height + @vgap

      end

      maxWidth += 2 * @hgap

      Dimension.new(maxWidth, height)
       
    end
   
    def minimumHorizontal parent

      width = @hgap
      maxHeight = 0

      for comp in parent.getComponents()

        dim = comp.getPreferredSize()

        maxHeight = maxHeight < dim.height ? dim.height : maxHeight

        width += dim.width + @hgap

      end

      maxHeight += 2 * @vgap

      Dimension.new(width, maxHeight)
       
    end
    
  end
  
  class FormLayout
	
    include LayoutManager
    
    attr_accessor :hgap, :vgap
    
    def initialize(hgap = 0, vgap = 0)
		
      @hgap = hgap
      @vgap = vgap
      
      @commands = []
      @components = []
      @number_of_elements = 1
      @layout_configured = false
      
      @delegate_layout = MigLayout.new("gapx #{hgap}, gapy #{vgap}", "grow", "")
		
    end
    
    def add_layout_extensions component
        
        if component.respond_to?(:form_layout_manager=)
          component.form_layout_manager = self
          return
        end
        
        def component.form_layout_manager= layout_mgr
          @layout_mgr = layout_mgr
        end
        
        component.form_layout_manager = self
        
        def component.layout_button child
          @layout_mgr.add_command child.java_component
        end
        def component.layout_label child
          @layout_mgr.add_panel child.java_component
        end
        def component.layout_input label, text
          if label
            @layout_mgr.add_field label.java_component, text.java_component
          else
            @layout_mgr.add_field label, text.java_component
          end
        end
        def component.layout_list label, list
          if label
            @layout_mgr.add_component label.java_component, list.java_component
          else
            @layout_mgr.add_component label, list.java_component
          end
        end        
        def component.layout_panel panel
          @layout_mgr.add_panel panel.java_component
        end
        
      end
      
    def add_field(label, text, helper = nil)

      n = 1
      n += label ? 1 : 0
      n += helper ? 1 : 0
      
      @components << [label, text, helper]
      
      @number_of_elements = n if @number_of_elements < n
      
    end
	
    def add_panel(panel)
      @components << [nil, panel, nil]
    end
	
    def add_component(label, comp)
      @components << [label, comp, nil]
    end
	
    def add_command(button)
      @commands << button
    end
	
    def addLayoutComponent(name, comp)
      @delegate_layout.addLayoutComponent(name, comp)
    end
	
    def removeLayoutComponent(comp)
      @delegate_layout.removeLayoutComponent(comp)
    end
    
    def preferredLayoutSize(parent)
      configure_layout
      @delegate_layout.preferredLayoutSize(parent)
    end
	
    def minimumLayoutSize(parent)
      configure_layout
      @delegate_layout.minimumLayoutSize(parent)
    end
	
    def maximumLayoutSize(parent)
      configure_layout
      @delegate_layout.maximumLayoutSize(parent)
    end
    
    def layoutContainer(parent)
      configure_layout
      @delegate_layout.layoutContainer(parent)
    end

    def configure_layout
      
      return if @layout_configured
      
      constraint = case @number_of_elements
        when 1
          "[grow]"
        when 2
          "[][grow]"
        when 3
          "[][grow][]"
      end
      
      @delegate_layout.setColumnConstraints constraint

      @components.each do |label, comp, helper|
  
        if label
          @delegate_layout.addLayoutComponent label, ""
          @delegate_layout.addLayoutComponent comp, "growx" if helper
          @delegate_layout.addLayoutComponent helper, "wrap" if helper
          @delegate_layout.addLayoutComponent comp, "growx, wrap" unless helper
        elsif @number_of_elements == 1
          @delegate_layout.addLayoutComponent comp, "growx" if helper
          @delegate_layout.addLayoutComponent helper, "wrap" if helper
          @delegate_layout.addLayoutComponent comp, "growx, wrap" unless helper
        else
          @delegate_layout.addLayoutComponent comp, "skip 1, growx" if helper
          @delegate_layout.addLayoutComponent helper, "wrap" if helper
          @delegate_layout.addLayoutComponent comp, "skip 1, growx, wrap" unless helper
        end
      
      end
      
      @commands.reverse_each do |button|
  
        @delegate_layout.addLayoutComponent button, "sgx commands, cell 0 #{@components.length}, spanx, align right"
      
      end
      
      @layout_configured = true
      
    end
    
  end
  
  class StackedLayout
	
    include LayoutManager
    
    attr_accessor :change_layout
    attr_accessor :hgap, :vgap, :direction, :alignment, :sizing
    
    def initialize(hgap = 0, vgap = 0, direction = :vertical, align = :center, sizing = :normal)
		
      @hgap = hgap
      @vgap = vgap
      @sizing = sizing
      @alignment = align
      @direction = direction
      
      @change_layout = []
      
    end
	
    def add_layout_extensions component
      
      def component.stacked_layout_manager= lm
        @stacked_layout_manager = lm
      end
      
      def component.align *x
        @stacked_layout_manager.change_layout.push [self.java_container.component_count] + x
      end

      def component.bottom
        @stacked_layout_manager.change_layout.push [self.java_container.component_count] + [:bottom]
      end
      
      component.stacked_layout_manager = self
      
    end
    
    def addLayoutComponent(name, comp)
      raise NotImplementedError.new
    end
	
    def removeLayoutComponent(comp)
      raise NotImplementedError.new
    end
	
    def preferredLayoutSize(parent)
      minimumLayoutSize parent
    end
    
    def minimumLayoutSize(parent)
       
      if @direction == :horizontal
        minimumHorizontal parent
      else
        minimumVertical parent
      end
      
    end
    
    def layoutContainer parent

      if @direction == :horizontal
        layoutHorizontal parent
      else
        layoutVertical parent
      end

    end
    
    private 
    
    def layoutVertical parent
       
      x = @hgap
      y = @vgap

      width = parent.width - 2 * @hgap
      
      if @sizing == :maximum
        
        max_width = 0
        
        for comp in parent.getComponents()

          dim = comp.getPreferredSize()
          
          max_width = dim.width if max_width < dim.width
          
        end
        
      end

      bottom_index = nil
      component_index = 0
      layout_change_index = 0
      
      alignment = @alignment
      
      for comp in parent.getComponents()

        if layout_change_index < @change_layout.length
          
          while layout_change_index < @change_layout.length and 
              @change_layout[layout_change_index][0] == component_index
            
            if @change_layout[layout_change_index][1] == :bottom
              bottom_index = component_index
            else
              alignment = @change_layout[layout_change_index][1]
            end
            
             layout_change_index += 1
              
          end
          
        end
        
        dim = comp.getPreferredSize()

        dim.width = max_width if max_width
        
        if alignment == :center
          x = @hgap + (width - dim.width) / 2
        elsif alignment == :right
          x = @hgap + width - dim.width
        else
          x = @hgap
        end

        comp.setBounds(x, y, dim.width, dim.height)

        y += dim.height + @vgap
        
        component_index += 1

      end
      
      if bottom_index
        
        offset = parent.height - y
        
        if offset > 0
          
          kids = parent.getComponents()

          while bottom_index < component_index
            p = kids[bottom_index].getLocation
            kids[bottom_index].setLocation(p.x, p.y + offset)
            bottom_index += 1
          end
          
        end
        
      end
       
    end

    def layoutHorizontal parent
       
      x = @hgap
      y = @vgap

      height = parent.height - 2 * @vgap
      
      if @sizing == :maximum
        
        max_height = 0
        
        for comp in parent.getComponents()

          dim = comp.getPreferredSize()
          
          max_height = dim.height if max_height < dim.height
          
        end
        
      end

      bottom_index = nil
      component_index = 0
      layout_change_index = 0
      
      alignment = @alignment

      for comp in parent.getComponents()

        if layout_change_index < @change_layout.length
          
          if @change_layout[layout_change_index][0] == component_index
            
            if @change_layout[layout_change_index][1] == :bottom
              bottom_index = component_index
            else
              alignment = @change_layout[layout_change_index][1]
            end
            
             layout_change_index += 1
              
          end
          
        end

        dim = comp.getPreferredSize()

        dim.height = max_height if max_height

        if @alignment == :center
          y = @vgap + (height - dim.height) / 2
        elsif @alignment == :right
          y = @vgap + height - dim.height
        else
          y = @vgap
        end

        comp.setBounds(x, y, dim.width, dim.height)

        x += dim.width + @hgap
        
        component_index += 1

      end
      
      if bottom_index
        
        offset = parent.width - x
        
        if offset > 0
          
          kids = parent.getComponents()

          while bottom_index < component_index
            p = kids[bottom_index].getLocation
            kids[bottom_index].setLocation(p.x + offset, p.y)
            bottom_index += 1
          end
          
        end
        
      end
       
    end
   
    def minimumVertical parent

      height = @vgap
      maxWidth = 0

      for comp in parent.getComponents()

        dim = comp.getPreferredSize()

        maxWidth = maxWidth < dim.width ? dim.width : maxWidth

        height += dim.height + @vgap

      end

      maxWidth += 2 * @hgap

      Dimension.new(maxWidth, height)
       
    end
   
    def minimumHorizontal parent

      width = @hgap
      maxHeight = 0

      for comp in parent.getComponents()

        dim = comp.getPreferredSize()

        maxHeight = maxHeight < dim.height ? dim.height : maxHeight

        width += dim.width + @hgap

      end

      maxHeight += 2 * @vgap

      Dimension.new(width, maxHeight)
       
    end
    
  end

end