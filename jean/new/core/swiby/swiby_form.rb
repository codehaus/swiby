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

require 'swiby'
require 'swiby_layouts'

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

    def initialize

      super

      setup

    end

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
    end
    
    def data obj
      @data = obj
    end

    def next_row
      @section = nil
      @main_layout.add_area :next_row
    end
    
    def apply_restore
      
      button "Apply" do
        
        if @updaters
          
          @updaters.each do |proc|
            proc.call false
          end
          
        end
        
      end
      
      button "Restore" do
        
        if @updaters
          
          @updaters.each do |proc|
            proc.call true
          end
          
        end
        
      end

    end

    def section(title = nil)

      @layout = FormLayout.new(10, 5)

      @section = JPanel.new
      @section.layout = @layout
      @section.border = Swing::BorderFactory.createTitledBorder(title) unless title.nil?
      @content_pane.add @section

      @main_layout.add_area @section

    end

    def add child
      @section.add child.java_component
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

  end

end