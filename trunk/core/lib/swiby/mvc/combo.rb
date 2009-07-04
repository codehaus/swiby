#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/combo'

module Swiby
  
  class ComboBox
    
    include SelectableComponendBehavior
    
    def register master, controller, id, method_naming_provider
      super
      
      need_getter_method
      need_setter_method
      
      need_list_method
      need_list_changed_method
      
      added_self = false
      
      if @getter_method
        master.wrappers << self
        added_self = true
      end

      if @setter_method
        add_listener create_listener
        master.wrappers << self unless added_self
      end
      
    end
    
    def create_listener
      ClickAction.new(self)
    end
    
    def add_listener listener
      listener.install @component
    end
    
    def execute_action
      @controller.send(@setter_method, self.value)
      @master.refresh
    end
    
  end
  
end