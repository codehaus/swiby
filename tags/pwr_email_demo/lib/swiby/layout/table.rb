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

  class TableLayoutFactory
    
    def accept name
      name == :table
    end
  
    def create name, data
      
      layout = TableLayout.new
      
      layout.hgap = data[:hgap] if data[:hgap]
      layout.vgap = data[:vgap] if data[:vgap]
      
      layout
      
    end
    
  end
  
  LayoutFactory.register_factory(TableLayoutFactory.new)
  
  class TableLayout
	
    include LayoutManager
    
    attr_accessor :hgap, :vgap

    def add_layout_extensions component
        
        if component.respond_to?(:swiby_table__actual_add)
          component.table_layout_manager = self
          return
        end
        
        class << component
          alias :swiby_table__actual_add :add
        end
        
        def component.table_layout_manager= layout_mgr
          @layout_mgr = layout_mgr
        end
        
        component.table_layout_manager = self
        
        def component.add child
          
          swiby_table__actual_add child
          
          @layout_mgr.add child
          
        end
        
        def component.row
          @layout_mgr.row
        end
        
        def component.cell options = {}
          
          align = options[:align]
          span = options[:span]
          
          align = :left unless align
          span = 1 unless span
          
          @layout_mgr.cell span, align
          
        end
        
    end
    
    def initialize hgap = 0, vgap = 0
      
      @hgap, @vgap = hgap, vgap
      
      @rows = []
      @components = []
      
    end

    def row
      @rows << []
    end
    
    def cell span = 1, align = :left
      
      @current = CellData.new(span, align)
      
      @rows.last << @current
      
    end
    
    def add comp
      
      @minimum_columns_widths = nil
      @preferred_columns_widths = nil
      
      @current.components << comp

    end
    
    def layoutContainer parent
      
      compute_column_widths
      
      y = @vgap
      
      @rows.each do |row|
        
        x = @hgap
        row_height = 0
        
        row.each do |cell|
          
          cell.components.each do |comp|
            dim = comp.java_component.getPreferredSize
            row_height = dim.height if row_height < dim.height
          end
          
        end
        
        i = 0
        
        row.each do |cell|
          
          cell_width = 0
          
          cell.span.times do
            cell_width += @preferred_columns_widths[i] + @hgap
            i += 1
          end
          
          width_offset = 0
          
          if cell.align == :center
            width_offset = (cell_width - cell.preferred_size[0]) / 2
          elsif cell.align == :right
            width_offset = cell_width - cell.preferred_size[0]
          end
          
          x_cell = x + width_offset
          
          cell.components.each do |comp|
            
            dim = comp.java_component.getPreferredSize
            
            height_offset = (row_height - dim.height) / 2
            
            comp.setBounds(x_cell, y + height_offset, dim.width, dim.height)
            
            x_cell += dim.width
            
          end
          
          x += cell_width
          
        end
        
        y += row_height + @vgap
        
      end
      
    end
    
    def minimumLayoutSize parent
      preferredLayoutSize parent
    end
    
    def preferredLayoutSize parent
      
      compute_column_widths
      
      height = @vgap
      
      @rows.each do |row|
        
        row_height = 0
        
        row.each do |cell|
          w, h = cell.preferred_size
          row_height = h if row_height < h
        end
        
        height += row_height + @vgap
        
      end
      
      width = @hgap
      
      @preferred_columns_widths.length.times do |i|
        width += @preferred_columns_widths[i] + @hgap
      end
      
      Dimension.new(width, height)
      
    end
    
    def addLayoutComponent(name, comp)
      raise NotImplementedError.new
    end
	
    def removeLayoutComponent(comp)
      
      @minimum_columns_widths = nil
      @preferred_columns_widths = nil
      
      @rows.each do |row|
        row.each do |data|
          data.components.delete_if { |c| comp == c.java_component }
        end
        row.delete_if { |data| data.components.size == 0 }
      end
      
      @rows.delete_if { |row|  row.size == 0 }
      
    end
    
    class CellData

      attr_accessor :components, :span, :align
      
      def initialize span = 1, align = :left
        @components = []
        raise "invalid value for span" if span.nil?
        raise "invalid value for align" if align.nil?
        @span, @align = span, align
      end
      
      def minimum_size
        compute_size { |comp| comp.java_component.getMinimumSize }
      end
      
      def preferred_size
        compute_size { |comp| comp.java_component.getPreferredSize }
      end
      
      private
      
      def compute_size
        
        cell_width = 0
        cell_height = 0
        
        @components.each do |comp|
          
          dim = yield(comp)
          
          cell_width += dim.width
          cell_height = dim.height unless cell_height > dim.height
          
        end
        
        return cell_width, cell_height
        
      end
      
    end
    
    private
    
    def compute_column_widths
      
      return if @preferred_columns_widths
      
      initialize_columns

      span = 1
      
      begin
        
        has_higher_span = false
        
        @rows.each do |row|
          
          i = 0
          
          row.each do |cell|
            
            has_higher_span |= cell.span > span
          
            if cell.span == span
              
              w, h = cell.preferred_size
              
              current_w = 0
              
              (i ... i + cell.span).each do |j|
                current_w += @preferred_columns_widths[j]
              end
              
              if w > current_w
                
                spacing = (w - current_w) / span
                
                (i ... i + cell.span).each do |j|
                  @preferred_columns_widths[j] = @preferred_columns_widths[j] + spacing
                end
                
              end
              
            end
          
            i += cell.span
            
          end
          
        end
        
        span += 1
        
      end while has_higher_span
        
    end
    
    def initialize_columns
      
      col_count = 0
      
      @rows.each do |row|
        
        row_col_count = 0
        
        row.each do |cell|
          row_col_count += cell.span
        end
        
        col_count = row_col_count if col_count < row_col_count
        
      end
      
      @preferred_columns_widths = [0] * col_count
      
    end
    
  end

end