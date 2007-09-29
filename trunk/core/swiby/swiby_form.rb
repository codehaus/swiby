#--
# BSD license
# 
# Copyright (c) 2007, Jean Lazarou
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice, this list 
# of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this 
# list of conditions and the following disclaimer in the documentation and/or other
# materials provided with the distribution. 
# Neither the name of the null nor the names of its contributors may be 
# used to endorse or promote products derived from this software without specific 
# prior written permission. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
# OF THE POSSIBILITY OF SUCH DAMAGE.
#++

#TODO improve layout managers (glitches when resizong and use of preferred sometimes results in bad layouts
require 'swiby'

module Swiby

module Swing
	include_class 'javax.swing.JTable'
	include_class 'javax.swing.BorderFactory'
	include_class 'javax.swing.table.DefaultTableModel'
end

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

class FormLayout
	
	include AWT::LayoutManager
	
	def initialize(hgap = 0, vgap = 0)
		
		@hgap = hgap
		@vgap = vgap
		
		@labels = []
		@fields = []
		@helpers = []
		@commands = []
		@components = []
		
	end
	
	def add_field(label, text)
		@labels.push(label)
		@fields.push(text)
		@helpers.push(nil)
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
		bonusH = ci.cumulatedHeight + (fi.count + ci.count + 1) * @vgap + bi.maxHeight + @vgap

		if fi.maxHeight < hi.maxHeight
			bonusH += fi.maxHeight * (fi.count - hi.count) + hi.maxHeight * hi.count
		else
			bonusH += fi.maxHeight * fi.count
		end
		
		bonusH = ci.count != 0 && bonusH < h ? (h - bonusH) / ci.count : 0
		
		i = 0
		
		@labels.each do |c|

			if !c.nil?
				c.setBounds(x, y, li.maxWidth, li.maxHeight)
			end

			c = @fields[i]

			if !c.nil? && c.visible?
				
				c.setBounds(x + li.maxWidth + @hgap, y, ci.minWidth, fi.maxHeight)

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
		y = insets.top + h - @vgap - bi.maxHeight
		
		@commands.each do |c|

			next if !c.visible?
			
			x -= bi.maxWidth + @hgap
			
			c.setBounds(x, y, bi.maxWidth, bi.maxHeight)
			
		end
		
	end
	
	def compute_size(parent, li, fi, ci, hi, bi)
		
		insets = full_insets(parent)

		nLines = li.count > (fi.count + ci.count) ? li.count : fi.count + ci.count

		w = li.maxWidth + @hgap + (fi.maxWidth < ci.maxWidth ? ci.maxWidth : fi.maxHeight) + @hgap + hi.maxWidth + @hgap
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
		
		insets = full_insets(parent)

		w = parent.size.width - (insets.left + insets.right) - @hgap
		h = parent.size.height - (insets.top + insets.bottom) - @vgap

		x = insets.left + @hgap
		y = insets.top + @vgap
    
		heights = []
    cols_per_row = []
    
    cols = 0
		height_max = 0
    
    @areas.each do |p|
      
      if p == :next_line
      
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
    
		i = 0
		
    @areas.each do |p|
      
      if p == :next_line
			
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
      
      if p == :next_line

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
	
end

Swiby::component_factory :Form

#TODO  bind half-implemented and bad!
#TODO  check for lot of duplication code
class Form < Frame

	def initialize

		super
		
		setup
		
	end

	def setup
		
		@section = nil
		
		@component.content_pane = JPanel.new
		
    @main_layout = AreaLayout.new(5, 5)
		@component.content_pane.layout = @main_layout
		
	end
	
	def content(&block)

		block.call
		
	end

	def section(title = nil)
  
		@layout = FormLayout.new(10, 5)
		
		@section = JPanel.new
		@section.layout = @layout
		@section.border = Swing::BorderFactory.createTitledBorder(title) unless title.nil?
		@component.content_pane.add @section
    
    @main_layout.add_area @section
    
	end
			
	def input(label, value)

		section if @section.nil?
		
		if label.instance_of? IncrementalValue
				jlabel = JLabel.new(label.get_value.to_s)
		else
				jlabel = JLabel.new(label.to_s)
		end
		
		if value.instance_of? IncrementalValue
				jtext = JTextField.new(value.get_value.to_s)
		else
				jtext = JTextField.new(value.to_s)
		end
		
		jlabel.label_for = jtext
		
		@section.add jlabel
		@section.add jtext
		
		@layout.add_field jlabel, jtext
	
	end
	
	def next_line
		@section = nil
    @main_layout.add_area :next_line
	end
	
	def button title, &block

		section if @section.nil?
		
		if title.instance_of? IncrementalValue
				jbutton = JButton.new(title.get_value.to_s)
		else
				jbutton = JButton.new(title.to_s)
		end
		
		@section.add jbutton
		
		@layout.add_command jbutton
	
		listener = ActionListener.new
		
		jbutton.addActionListener(listener)
		
		listener.register &block
		
	end
	
	def choice label, values, selected = nil

		section if @section.nil?
		
		if label.instance_of? IncrementalValue
				jlabel = JLabel.new(label.get_value.to_s)
		else
				jlabel = JLabel.new(label.to_s)
		end
		
    combo = JComboBox.new
    
		if values.instance_of? IncrementalValue
      values = values.get_value
		end

    select_index = -1
    
    values.each do |value|
      
			if value.respond_to? :humanize
				display = value.humanize
			elsif value.respond_to? :name
				display = value.name
			else
				display = value.to_s
			end
			
      combo.addItem display
			
			select_index = combo.item_count - 1 if value == selected
      
    end

    combo.selected_index = select_index unless select_index == -1
		
		@section.add jlabel
		@section.add combo
    
		@layout.add_field jlabel, combo
    
  end
	
	def table headers, values

		section if @section.nil?
		
		if values.instance_of? IncrementalValue
      values = values.get_value
		end
		
		model = Swing::DefaultTableModel.new
		
		headers.each do |column|
			model.addColumn column
		end
		
		values.each do |value|
		
			row = value.table_row
		
			vector = java.util.Vector.new
			
			row.each do |cell|
				vector.addElement cell
			end
		
			model.addRow vector
			
		end
		
		table = Swing::JTable.new
		table.model = model

		table.auto_resize_mode = Swing::JTable::AUTO_RESIZE_SUBSEQUENT_COLUMNS
		table.selection_model.selection_mode = javax.swing.ListSelectionModel::SINGLE_SELECTION
		
		pane = JScrollPane.new(table)
		
		@section.add pane
    
		@layout.add_panel pane
		
	end
	
	def list label, values, selected = nil

		section if @section.nil?
		
		if label.instance_of? IncrementalValue
				jlabel = JLabel.new(label.get_value.to_s)
		else
				jlabel = JLabel.new(label.to_s)
		end
		
		model = DefaultListModel.new
		
    list = JList.new
		list.model = model
		
		if values.instance_of? IncrementalValue
      values = values.get_value
		end

    select_index = -1
    
    values.each do |value|
      
			if value.respond_to? :humanize
				display = value.humanize
			elsif value.respond_to? :name
				display = value.name
			else
				display = value.to_s
			end
			
      model.addElement display
			
			select_index = model.size - 1 if value == selected
      
    end

    list.selected_index = select_index unless select_index == -1
		
		pane = JScrollPane.new(list)
		
		@section.add jlabel
		@section.add pane
    
		@layout.add_component jlabel, pane
    
	end
	
end

end