#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby'
require 'swiby/swing/layout'

class Symbol

  def / other_sym

    raise TypeError.new("Expected Symbol but was #{other_sym.class}") unless other_sym.instance_of?(Symbol)

    AccessorPath.new(self, other_sym)

  end

end

module Swiby

  module Swing
    include_class 'javax.swing.JTable'
    include_class 'javax.swing.BorderFactory'
    include_class 'javax.swing.table.DefaultTableModel'
  end

  # valid options are :as_panel or :as_frame
  def form(*options, &block)

    is_panel = false

    if options.length == 0
      is_panel = false
    elsif options[0] == :as_panel
      is_panel = true
    end

    if is_panel
      x = ::Panel.new
    else
      x = ::Frame.new
    end

    x.extend(Form)
    x.setup is_panel

    x.instance_eval(&block) unless block.nil?

    x

  end

  module Form

    def setup is_panel = false

      local_context = self #TODO pattern repeated at several places!

      self.instance_eval do

        @local_context = local_context

        def context()
          @local_context
        end

      end
      
      @section = nil

      if is_panel
        @content_pane = self.java_component
      else
        @content_pane = JPanel.new
        @component.content_pane = @content_pane
      end

      @main_layout = AreaLayout.new(5, 5)
      @content_pane.layout = @main_layout

    end

    def content(&block)
      
      block.call
      
      complete
      
    end
    
    def data obj
      @data = obj
    end

    def next_row
      @section = nil
      @main_layout.add_area :next_row
    end
    
    def apply_restore
      
      button "Apply", :name => :apply_but do
        
        if @updaters
          
          @updaters.each do |proc|
            proc.call false
          end
          
        end

        context[:apply_but].enabled = false
        context[:restore_but].enabled = false
        
      end
      
      button "Restore", :name => :restore_but  do
        
        if @updaters
          
          @updaters.each do |proc|
            proc.call true
          end
          
        end

        context[:apply_but].enabled = false
        context[:restore_but].enabled = false
        
      end

    end

    def section(title = nil)

      @layout = FormLayout.new(10, 5)
      
      @section = Section.new title
      @section.layout = @layout
      
      context << @section
      
      @content_pane.add @section.java_component

      @main_layout.add_area @section

    end

    def add child
      @section.add child
    end
    
    def ensure_section()
      section if @section.nil?
    end

    def layout_button comp = nil
      @layout.add_command comp.java_component
    end

    def layout_input label, text 
      @layout.add_field label.java_component, text.java_component
    end
    
    def layout_list label, list
      @layout.add_component label.java_component, list.java_component
    end

    def complete
      
      unless context[:apply_but].nil?
      
        context.each(TextField) do |tf|

          tf.on_change do
            context[:apply_but].enabled = true
            context[:restore_but].enabled = true
          end
          
        end
        
        context[:apply_but].enabled = false
        context[:restore_but].enabled = false
          
      end
      
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
      
      #TODO create a Swiby::ScrollPane?
      def pane.java_component
        self
      end

      @section.add pane

      @layout.add_panel pane

    end

  end

end