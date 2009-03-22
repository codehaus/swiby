#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/table'

module Swiby
  
  class Table
    
    def register master, controller, id, method_naming_provider
      
      super
        
      need_getter_method
      need_selection_handler_method
      
      added_self = false
      
      if @getter_method
        master.wrappers << self
        added_self = true
      end

      if @selection_handler_method
        add_listener create_listener
        master.wrappers << self unless added_self
      end
      
      #TODO improve making table read-only
      @component.setDefaultEditor(@component.getColumnClass(0), nil)
      
    end
    
    def create_listener
      SelectionAction.new(self)
    end
    
    def add_listener listener
      listener.install @component
    end
    
    def display values
      
      clear
      
      return unless values
    
      model.values = values
      
    end
    
    def selection_changed
      
      if @selection_handler_method
        @controller.send(@selection_handler_method, @component.getSelectedRow)
        @master.refresh
      end
      
    end
    
  end
  
end