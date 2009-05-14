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

          addRow vector

        end
        
      end
      
      def fields= fields
        @fields = fields
      end
      
    end
    
    def table headers, values = nil

      ensure_section
      
      name, fields = nil, nil
      
      options = values if values.is_a?(Hash)
      options = headers if headers.is_a?(Hash) and values.nil?
      
      if options
        
        values = []
        
        name = options[:name] if options[:name]
        values = options[:data] if options[:data]
        fields = options[:fields] if options[:fields]
        headers = options[:columns] if options[:columns]
                
      end

      model = TM.new
      model.headers = headers
      model.values = values
      model.fields = fields
      
      table = Table.new
      table.model = model
      table.fields = fields

      context[name.to_s] = table if name
      table.name = name.to_s if name

      add table
      context << table
      layout_panel table

    end

  end
  
  class Table < SwingBase

    attr_accessor :fields
    
    def initialize
      
      @component = JTable.new
      
      @component.auto_resize_mode = JTable::AUTO_RESIZE_SUBSEQUENT_COLUMNS
      @component.selection_model.selection_mode = javax.swing.ListSelectionModel::SINGLE_SELECTION
      
      scrollable

    end
    
    def model= model
      @component.model = model
    end
    
    def model
      @component.model
    end
    
    def clear
      model.row_count = 0
    end
    
    def apply_styles styles
      
      set_renderers
      
      color = styles.resolver.find_color(:table)
        
      bg_color = styles.resolver.find_background_color(:table)
      bg_color = styles.resolver.find_background_color(:container) unless bg_color
      @component.parent.background = bg_color if bg_color

      font = styles.resolver.find_font(:table_header)
      font = styles.resolver.find_font(:table) unless font
      @header_renderer.font = font
      
      header_bg_color = styles.resolver.find_background_color(:table_header)
      header_bg_color = bg_color unless header_bg_color
      @header_renderer.background = header_bg_color if header_bg_color
      
      header_color = styles.resolver.find_color(:table_header)
      header_color = color unless header_bg_color
      @header_renderer.foreground = header_color if header_color
        
      if @component.model.row_count > 0

        row_bg_color = styles.resolver.find_background_color(:table_row)
        row_bg_color = bg_color unless row_bg_color
        @renderer.background = row_bg_color if row_bg_color
        
        row_color = styles.resolver.find_color(:table_row)
        row_color = color unless row_color
        @renderer.foreground = row_color if row_color
        
        @renderer.text = 'test'
        height = @renderer.preferred_size.height
        font = styles.resolver.find_font(:table_row)
        font = styles.resolver.find_font(:table) unless font
        @component.font = font if font
        @renderer.font = font if font
        height = @renderer.preferred_size.height - height
        @component.row_height += height unless @component.row_height + height < 1
        
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
