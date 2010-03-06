#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/mvc/combo'
require 'swiby/component/list'

module Swiby
  
  class ListBox
    
    class ListRegistrar < ComboRegistrar
      
      def register
      
        super
        
        need_remove_item_method
        need_selected_indexes_method
        
        if @selected_indexes_method
          
          add_listener create_listener
          @master << self
          
          @component.selection_mode = javax.swing.ListSelectionModel::MULTIPLE_INTERVAL_SELECTION
          
        elsif @setter_method or @value_index_setter_method          
          @component.selection_mode = javax.swing.ListSelectionModel::SINGLE_SELECTION
        end
          
        if @remove_item_method
          
          renderer = @component.cell_renderer
          
          #org.codehaus.swiby.gesture.ImageListRemovalGesture.new(@component)
          
          listener = DataAction.new(self)
          listener.install @component
          
        end
        
      end
      
      def create_listener
        SelectionAction.new(self)
      end
      
      def selection_changed
        
        if @selected_indexes_method
          
          @controller.send(@selected_indexes_method, *@component.getSelectedIndices.to_a)
          
          @master.refresh
          
        else
          execute_action
        end
              
      end
      
      def item_removed item_index
        @controller.send(@remove_item_method, item_index)
      end
      
      def handles_actions?
        super or !@selected_indexes_method.nil?
      end
      
    end
    
    def create_registrar wrapper, master, controller, id, method_naming_provider
      ListRegistrar.new(wrapper, master, controller, id, method_naming_provider)
    end
    
  end
  
end