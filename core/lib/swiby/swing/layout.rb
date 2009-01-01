#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'java'

module Swiby

  module AWT
    include_class 'java.awt.LayoutManager'
  end

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

  class ComponentsInfo

    attr_accessor :count, :maxWidth, :maxHeight, :minWidth, :cumulatedHeight

    def self.createPreferredInfo(components)
      createInfo components do |c|
        c.preferred_size
      end
    end

    def self.createMinimumInfo(components) 
      createInfo components do |c|
        c.minimum_size
      end
    end

    private 
	
    def self.createInfo(components)
		
      info = ComponentsInfo.new
		
      components.each do |c|
			
        if not c.nil? and c.visible?
				
          info.count += 1

          size = yield(c)
				
          if info.maxWidth < size.width
            info.maxWidth = size.width
          end
          if info.maxHeight < size.height
            info.maxHeight = size.height
          end

          if info.minWidth > size.width
            info.minWidth = size.width
          end
				
          info.cumulatedHeight += size.height
				
        end
			
      end
		
      info

    end
	
    def initialize
      @count = 0
      @maxWidth = 0
      @maxHeight = 0
      @minWidth = -1
      @cumulatedHeight = 0
    end
	
  end


  class StackedLayout
	
    include AWT::LayoutManager
    
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

      AWT::Dimension.new(maxWidth, height)
       
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

      AWT::Dimension.new(width, maxHeight)
       
    end
    
  end
  
  class FormLayout
	
    include AWT::LayoutManager
	
    attr_accessor :hgap, :vgap
    
    def initialize(hgap = 0, vgap = 0)
		
      @hgap = hgap
      @vgap = vgap
		
      @labels = []
      @fields = []
      @helpers = []
      @commands = []
      @components = []
		
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
      @labels.push(label)
      @fields.push(text)
      @helpers.push(helper)
      @components.push(nil)
    end
	
    def add_panel(panel)
      @labels.push(nil)
      @fields.push(nil)
      @helpers.push(nil)
      @components.push(panel)
    end
	
    def add_component(label, comp)
      @labels.push(label)
      @fields.push(nil)
      @helpers.push(nil)
      @components.push(comp)
    end
	
    def add_command(button)
      @commands.push(button)
    end
	
    def addLayoutComponent(name, comp)
      raise NotImplementedError.new
    end
	
    def removeLayoutComponent(comp)
      raise NotImplementedError.new
    end
	
    def preferredLayoutSize(parent)
	
      li = ComponentsInfo.createPreferredInfo(@labels)
      fi = ComponentsInfo.createPreferredInfo(@fields)
      ci = ComponentsInfo.createPreferredInfo(@components)
      bi = ComponentsInfo.createPreferredInfo(@commands)
      hi = ComponentsInfo.createPreferredInfo(@helpers)
    
      compute_size(parent, li, fi, ci, hi, bi)
		
    end
	
    def minimumLayoutSize(parent)

      li = ComponentsInfo.createMinimumInfo(@labels)
      fi = ComponentsInfo.createMinimumInfo(@fields)
      ci = ComponentsInfo.createMinimumInfo(@components)
      bi = ComponentsInfo.createMinimumInfo(@commands)
      hi = ComponentsInfo.createMinimumInfo(@helpers)
		
      compute_size(parent, li, fi, ci, hi, bi)
			
    end
	
    def layoutContainer(parent)

      li = ComponentsInfo.createMinimumInfo(@labels)
      fi = ComponentsInfo.createMinimumInfo(@fields)
      ci = ComponentsInfo.createMinimumInfo(@components)
      bi = ComponentsInfo.createMinimumInfo(@commands)
      hi = ComponentsInfo.createMinimumInfo(@helpers)
		
      insets = full_insets(parent)

      w = parent.size.width - (insets.left + insets.right)
      h = parent.size.height - (insets.top + insets.bottom)
      
      min_size = minimumLayoutSize(parent)
      w = min_size.width if w < min_size.width
      h = min_size.height if w < min_size.height

      x = insets.left + @hgap
      y = insets.top + @vgap

      if ci.minWidth < fi.maxWidth
        ci.minWidth = fi.maxWidth
      end

      gaps = 3
		
      gaps = 4 if hi.count > 0
		
      if ci.minWidth < w - @hgap * gaps - li.maxWidth - hi.maxWidth
        ci.minWidth = w - @hgap * gaps - li.maxWidth - hi.maxWidth
      end

      centerHelper = (fi.maxHeight - hi.maxHeight) / 2
      neededH = ci.cumulatedHeight + (fi.count + ci.count + 1) * @vgap + bi.maxHeight + @vgap

      if fi.maxHeight < hi.maxHeight
        neededH += fi.maxHeight * (fi.count - hi.count) + hi.maxHeight * hi.count
      else
        neededH += fi.maxHeight * fi.count
      end
		
      bonusH = ci.count != 0 && neededH > h ? (h - neededH) / ci.count : 0
		
      i = 0
		
      @labels.each do |c|

        if !c.nil?
          c.setBounds(x, y, li.maxWidth, li.maxHeight)
        end

        c = @fields[i]

        if !c.nil? && c.visible?
				
          c.setBounds(x + li.maxWidth + @hgap, y, ci.minWidth, fi.maxHeight)  if li.maxWidth > 0
          c.setBounds(x + li.maxWidth, y, ci.minWidth + @hgap, fi.maxHeight)  if li.maxWidth == 0

          c = @helpers[i]

          if !c.nil?
					
            c.setBounds(x + li.maxWidth + @hgap + ci.minWidth + @hgap, y + centerHelper, hi.maxWidth, hi.maxHeight)

            y += hi.maxHeight + @vgap

          else
            y += fi.maxHeight + @vgap
          end
				
      end
      
        c = @components[i]

        if !c.nil? && c.visible?
				
          compH = c.preferred_size.height + bonusH

          if compH > h 
            compH = ci.maxHeight + bonusH
          end
				
          c.setBounds(x + li.maxWidth + @hgap, y, ci.minWidth, compH)

          y += compH + @vgap
				
        end
			
        i += 1
			
      end
    
      x = insets.right + w
      
      bottom_y = insets.top + h - @vgap - bi.maxHeight
      y = bottom_y if bottom_y > y
		
      @commands.reverse_each do |c|

        next if !c.visible?
			
        x -= bi.maxWidth + @hgap
			
        c.setBounds(x, y, bi.maxWidth, bi.maxHeight)
			
      end
		
    end
	
    def compute_size(parent, li, fi, ci, hi, bi)
		
      insets = full_insets(parent)

      nLines = li.count > (fi.count + ci.count) ? li.count : fi.count + ci.count

      w = li.maxWidth + @hgap + (fi.maxWidth < ci.maxWidth ? ci.maxWidth : fi.maxWidth) + @hgap + hi.maxWidth + @hgap
      wBut = bi.count * bi.maxWidth + (bi.count- 1) * @hgap
      h = nLines * li.maxHeight + (nLines - 1) * @vgap
		
      hFld = ci.cumulatedHeight + (nLines - 1) * @vgap

      if fi.maxHeight < hi.maxHeight
        hFld += (fi.count - hi.count) * fi.maxHeight + fi.count * hi.maxHeight
      else
        hFld += fi.count * fi.maxHeight
      end
		
      if w < wBut
        w = wBut
      end
      if h < hFld
        h = hFld
      end

      h = h + @vgap + bi.maxHeight

      AWT::Dimension.new(insets.left + insets.right + w + 2 * @hgap,
        insets.top + insets.bottom + h + 2 * @vgap)
		
    end
	
  end

  class AreaLayout
	
    include AWT::LayoutManager
	
    def initialize(hgap = 0, vgap = 0)
		
      @hgap = hgap
      @vgap = vgap
		
      @areas = []
		
    end
	
    def add_area(panel)
      @areas.push(panel)
    end
	
    def addLayoutComponent(name, comp)
      raise NotImplementedError.new
    end
	
    def removeLayoutComponent(comp)
      raise NotImplementedError.new
    end
	
    def preferredLayoutSize(parent)
    
      compute_dimension(parent) do |comp|
        comp.preferred_size
      end
    
    end
	
    def minimumLayoutSize(parent)
    
      compute_dimension(parent) do |comp|
        comp.minimum_size
      end
		
    end
	
    def layoutContainer(parent)
		
      return if @areas.length == 0
      
      insets = full_insets(parent)

      w = parent.size.width - (insets.left + insets.right) - @hgap
      h = parent.size.height - (insets.top + insets.bottom) - @vgap

      heights = []
      cols_per_row = []
    
      # [1] compute all sizes
      cols = 0
      height_max = 0
    
      @areas.each do |p|
      
        if p == :next_row
      
          heights.push height_max
          cols_per_row.push cols
      
          cols = 0
          height_max = 0
        
        elsif p.visible?
        
          cols += 1
				
          height = p.preferred_size.height
				
          if height_max < height
            height_max = height
          end
				
        end
      
      end
    
      unless cols == 0
        heights.push height_max
        cols_per_row.push cols
      end
    
      # [2] optimize height
      optimize_height h, heights
    
      #  [3] perform layout (resize and move compoments)
      x = insets.left + @hgap
      y = insets.top + @vgap
    
      i = 0
		
      @areas.each do |p|
      
        if p == :next_row
			
          x = insets.left + @hgap
          y += heights[i] + @vgap
				
          i += 1
				
        elsif p.visible?
				
          n = cols_per_row[i]
				
          comp_width = (w - n * @hgap) / n
				
          p.setBounds(x, y, comp_width, heights[i])
				
          x += comp_width + @hgap
				
        end
      
      end
    
    end

    def compute_dimension parent
    
      max_width = 0;
      max_height = 0;
    
      row_width = 0
      row_height = 0
    
      @areas.each do |p|
      
        if p == :next_row

          if max_width < row_width
            max_width = row_width
          end

          if max_height < row_height
            max_height = row_height
          end
        
          row_width = 0
          row_height = 0
    
        elsif p.visible?
        
          row_width += @vgap if row_width > 0
          row_height += @hgap if row_height > 0
        
          size = yield(p)
				
          row_width += size.width
          row_height += size.height
        
        end

      end

      if max_width < row_width
        max_width = row_width
      end

      if max_height < row_height
        max_height = row_height
      end
    
      insets = parent.insets
    
      AWT::Dimension.new(insets.left + insets.right + max_width + 2 * @hgap,
        insets.top + insets.bottom + max_height + 2 * @vgap)

    end
	
    def optimize_height parent_height, heights
  
      parent_height -= @vgap * heights.size
    
      last_chance = false
      max_height = parent_height / heights.size
    
      used_height = 0
    
      while true
    
        big_guys = 0
      
        heights.each_index do |i|
      
          if heights[i] <= max_height
            used_height += heights[i]
          elsif last_chance
            heights[i] = max_height
          else
            big_guys += 1
          end
        
        end
      
        break if last_chance or big_guys == 0
      
        prev_max_height = max_height
      
        max_height = (parent_height - used_height) / big_guys if big_guys > 0

        last_chance = max_height <= prev_max_height
      
        used_height = 0
      
      end
		
    end
    
  end

end