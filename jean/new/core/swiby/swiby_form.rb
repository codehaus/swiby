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
require 'swiby_layouts'

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

  #TODO  bind half-implemented and bad!
  #TODO  check for lot of duplication code
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

    def next_row
      @section = nil
      @main_layout.add_area :next_row
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

    def layout_input label, text 
      @layout.add_field label.java_component, text.java_component
    end
    
    def layout_button comp = nil
      @layout.add_command comp.java_component
    end

    def choice label, values, selected = nil

      section if @section.nil?

      jlabel = create_label(label)

      combo = create_combo

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

      jlabel = create_label(label)

      model = DefaultListModel.new

      list = create_list
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

    def create_label(label)

      if label.instance_of? IncrementalValue
        jlabel = JLabel.new(label.get_value.to_s)
      else
        jlabel = JLabel.new(label.to_s)
      end

      jlabel

    end

    def create_list

      list = JList.new

      list

    end

    def create_combo

      combo = JComboBox.new

      combo

    end

  end

end