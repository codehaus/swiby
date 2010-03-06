#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc/frame'

require 'swiby/mvc/list'
require 'swiby/mvc/table'
require 'swiby/mvc/button'
require 'swiby/mvc/radio_button'

#--
# Code is rather complex, but it is generic for all kind of lists
# to unsure that their main difference is only 'visual' aspect
# only...
#++

class MVCComboxesTest < ManualTest
  
  manual 'Comboboxes with controller' do

    controller = Object.new
    
    lists_add_handlers controller
        
    ViewDefinition.bind_controller lists_create_view(:combo), controller
    
  end

  manual 'Comboboxes with view only' do

    view = lists_create_view(:combo)
    
    lists_add_handlers view

    ViewDefinition.bind_controller view
    
  end
  
end

class MVCListsTest < ManualTest
  
  manual 'Lists with controller' do

    controller = Object.new
    
    lists_add_handlers controller
        
    ViewDefinition.bind_controller lists_create_view(:list), controller
    
  end

  manual 'Lists with view only' do

    view = lists_create_view(:list)
    
    lists_add_handlers view

    ViewDefinition.bind_controller view
    
  end
  
end

class MVCRadioGroupsTest < ManualTest
  
  manual 'Groups with controller' do

    controller = Object.new
    
    lists_add_handlers controller
        
    ViewDefinition.bind_controller lists_create_view(:radio_group), controller
    
  end

  manual 'Groups with view only' do

    view = lists_create_view(:radio_group)
    
    lists_add_handlers view

    ViewDefinition.bind_controller view
    
  end
  
end

class MVCTablesTest < ManualTest
  
  manual 'Tables with controller' do

    controller = Object.new
    
    lists_add_handlers controller
        
    ViewDefinition.bind_controller lists_create_view(:table), controller
    
  end

  manual 'Tables with view only' do

    view = lists_create_view(:table)
    
    lists_add_handlers view

    ViewDefinition.bind_controller view
    
  end
  
end

def lists_create_view list_type
  
  title_text = case list_type
    when :radio_group
      'Radio groups'
    when :list
      'Lists'
    when :table
      'Tables'
    when :combo
      'Comboboxes'
  end
  
  form {
    
    case list_type
    when :radio_group
      def list_directive *args
        radio_group *args
      end
    when :list
      def list_directive *args
        list *args
      end
    when :combo
      def list_directive *args
        combo *args
      end
    when :table
      def list_directive *args
        table *args
      end
    end
    
    title title_text
    
    width 500
    height 700
    
    colors = ['blue', 'green', 'red', 'yellow']
    
    section 'Disabled'
      list_directive "With a name", colors, :name => :with_a_name
      list_directive "By controller", colors, :name => :disabled_by_controller
    
    section 'Enabled'
      list_directive "Due to setter", colors, :name => :enabled_by_setter
      list_directive "By controller", colors, :name => :enabled_by_controller
      
    next_row
    section "Change list's data"
      list_directive "Change my data", colors, :name => :variable_content
      button "Change data", :name => :switch_content
    
    next_row
    section 'selection by value, default is red'
      list_directive colors, :name => :one_item
    
    section 'selection by index, default is green'
      list_directive colors, :name => :one_item_index_notified

    if list_type == :list
      next_row
      
      section 'multi-item selection, default is blue'
        list colors, :name => :multi_item
      
      next_row
      
      section 'remove itmes'
        list colors, :name => :removable_list
        button 'Remove', :name => :remove_item
        
    end
    
    visible true
    
  }
  
end

def lists_add_handlers o
  
  class << o
    
    def disabled_by_controller= x
    end
    def may_disabled_by_controller?
      false
    end
    
    def enabled_by_setter= x
    end
    
    def enabled_by_controller= x
    end
    def may_enabled_by_controller?
      true
    end
    
    def one_item
      @list_value = 'red' unless @list_value
      @list_value
    end
    def one_item= x
      
      @list_value = x
      
      message_box "Your selection is '#{x.inspect}'"
      
    end
    
    def one_item_index_notified
      @list_index = 1 unless @list_index
      @list_index
    end
    def one_item_index_notified_index= index
      @list_index = index
      message_box "Your selection is '#{index}'"
    end
    
    def selected_multi_item= *indexes
      message_box "Your selection is #{indexes.inspect}"
    end
    
    def switch_content
      
      unless @data
        
        @data = [
          ['white', 'orange', 'magenta', 'pink', 'brown'], 
          ['small', 'medium', 'big'],
          ['patatoes', 'pastas', 'rice']
        ]
        
        @current_data = 0
        
      end
      
      @data_changed = true
      @current_data = (@current_data + 1).modulo(@data.length)
      
    end

    def list_of_variable_content
      @data_changed = false
      @data[@current_data]
    end
    def list_of_variable_content_changed?
      @data_changed = false unless @data_changed
      @data_changed
    end
    def variable_content= x
    end

    def removable_list= x
    end
    def remove_removable_list x
      message_box "Item #{x} removed"
    end
    
    def remove_item
      list = @window.find(:removable_list) if @window
      list = find(:removable_list) unless @window
      list.remove_at list.selection if list.selection >= 0
    end
    
  end
    
end
