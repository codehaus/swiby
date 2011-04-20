#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import javax.swing.JTable
import javax.swing.table.TableCellRenderer
import javax.swing.table.DefaultTableCellRenderer

module Swiby

  module Builder
    
    def table headers, values = nil, options = nil, &block

      ensure_section
      
      x = TableOptions.new(context, headers, values, options, &block)
      
      comp = Table.new(x)

      context[x[:name].to_s] = comp if x[:name]

      add comp
      context << comp
      layout_panel comp
      
      comp

    end

  end
  
  class TableOptions < ComponentOptions
    
    define "Table" do
      
      declare :label, [String], true
      declare :name, [String, Symbol], true
      declare :fields, [Array], true
      declare :columns, [Array], true
      declare :values, [Array, IncrementalValue]
      
      declare :swing, [Proc], true
      declare :enabled, [TrueClass, FalseClass], true
      declare :style_class, [String, Symbol], true
      
      overload :values
      overload :columns, :values
      
      overload :label, :values
      overload :label, :columns, :values
      
    end

  end
  
  class Table < SwingBase

    attr_accessor :fields
    swing_attr_accessor :enabled
    
    def initialize options = nil
      
      @component = JTable.new
      
      @component.auto_resize_mode = JTable::AUTO_RESIZE_SUBSEQUENT_COLUMNS
      @component.selection_model.selection_mode = javax.swing.ListSelectionModel::SINGLE_SELECTION
      
      return unless options
      
      @content_data = options[:values] if options[:values]
      
      values = []
      
      name = options[:name] if options[:name]
      values = options[:values] if options[:values]
      fields = options[:fields] if options[:fields]
      headers = options[:columns] if options[:columns]

      model = TM.new
      model.headers = headers if headers
      model.fields = fields
      model.values = values
      
      self.model = model
      self.fields = fields
      
      self.name = options[:name].to_s if options[:name]
      self.enabled_state = options[:enabled] unless options[:enabled].nil?
      
      @style_id = self.name.to_sym if self.name
      @style_class = options[:style_class] if options[:style_class]

      options[:swing].call(java_component) if options[:swing]

      scrollable
      
    end
    
    def model= model
      @component.model = model
    end
    
    def model
      @component.model
    end
    
    def clear
      self.model.row_count = 0
    end

    def content= values
      self.model.row_count = 0
      self.model.values = values
    end
    
    def value= value
      self.selection = @content_data.index(value)
    end
    
    def selection= index
      @component.setRowSelectionInterval(index, index)
    end
      
    def apply_styles styles
      
      set_renderers
      
      color = styles.resolver.find_color(:table)
        
      bg_color = styles.resolver.find_background_color(:table, @style_id, @style_class)
      bg_color = styles.resolver.find_background_color(:container, @style_id, @style_class) unless bg_color
      @component.parent.background = bg_color if bg_color

      font = styles.resolver.find_font(:table_header, @style_id, @style_class)
      font = styles.resolver.find_font(:table, @style_id, @style_class) unless font
      @header_renderer.font = font
      
      header_bg_color = styles.resolver.find_background_color(:table_header, @style_id, @style_class)
      header_bg_color = bg_color unless header_bg_color
      @header_renderer.background = header_bg_color if header_bg_color
      
      header_color = styles.resolver.find_color(:table_header, @style_id, @style_class)
      header_color = color unless header_bg_color
      @header_renderer.foreground = header_color if header_color
        
      if @component.model.row_count > 0

        row_bg_color = styles.resolver.find_background_color(:table_row, @style_id, @style_class)
        row_bg_color = bg_color unless row_bg_color
        @renderer.background = row_bg_color if row_bg_color
        
        row_color = styles.resolver.find_color(:table_row, @style_id, @style_class)
        row_color = color unless row_color
        @renderer.foreground = row_color if row_color
        
        @renderer.text = 'test'
        height = @renderer.preferred_size.height
        font = styles.resolver.find_font(:table_row, @style_id, @style_class)
        font = styles.resolver.find_font(:table, @style_id, @style_class) unless font
        @component.font = font if font
        @renderer.font = font if font
        height = @renderer.preferred_size.height - height
        @component.row_height += height unless @component.row_height + height < 1
        
      end
      
    end

    class TM < javax.swing.table.DefaultTableModel
      
      def headers= headers

        headers.each do |column|
          addColumn column
        end

      end
      
      def values= values

        if values.instance_of? IncrementalValue
          values = values.get_value
        end

        values.each do |value|

          if value.respond_to?(:table_row)
            row = value.table_row
          else
            row = value
          end

          vector = java.util.Vector.new

          if row.is_a?(Hash)
          
            @fields.each do |field|
              vector.addElement row[field]
            end
              
          else

            row.each do |cell|
              vector.addElement cell
            end
              
          end

		  addColumn '' if getColumnCount() == 0 #TODO what is better for default table header?
          addRow vector

        end
        
      end
      
      def fields= fields
        @fields = fields
      end
      
      def isCellEditable row, column
        false
      end
      
    end
    
    private
    
    def set_renderers

      unless @renderer

        @renderer = DefaultTableCellRenderer.new

        col_model = @component.getColumnModel

        for i in (0...col_model.getColumnCount)
          column = col_model.getColumn(i)
          column.setCellRenderer(@renderer)
        end

        @header_renderer = SwibyTableHeaderRenderer.new
        
        header = @component.getTableHeader
        header_renderer = header.getDefaultRenderer
      
        @header_renderer.delegate = header_renderer

        header.setDefaultRenderer @header_renderer
        
      end
      
    end
    
  end

  class SwibyTableHeaderRenderer
  
    include TableCellRenderer
    
    def delegate= delegate
      @delegate = delegate
    end
    
    def getTableCellRendererComponent table, value, isSelected, hasFocus, row, column
      
      comp = @delegate.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column)
      
      comp.font = @font if @font
      comp.foreground = @foreground if @foreground
      comp.background = @background if @background
      
      comp
      
    end
    
    def font= font
      @font = font
    end
    
    def background= background
      @background = background
    end
    
    def foreground= foreground
      @foreground = foreground
    end
    
  end
  
end
