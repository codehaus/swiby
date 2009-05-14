#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/button'

module Swiby

  class Button
    
    def register master, controller, id, method_naming_provider
      
      super
      
      need_action_method

      if @action_method
        
        listener = create_listener
        
        if listener
          master.wrappers << self
          add_listener(listener)
        end
      
      else
        @component.enabled = false
      end
      
    end
    
    def create_listener
      ClickAction.new(self)
    end
      
    def add_listener listener
      listener.install @component
    end
    
    def execute_action
      @controller.send @action_method
      @master.refresh
    end

    def click
      @component.doClick
    end

    def enabled
      @component.enabled
    end

  end
  
end