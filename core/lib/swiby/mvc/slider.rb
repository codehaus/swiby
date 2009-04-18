#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/slider'

module Swiby

  class MethodNamingProvider
    
    def value_adjusting_method(id)
      "adjusting_#{id}".to_sym
    end
    
  end
  
  class Slider
    
    def register master, controller, id, method_naming_provider
      super
      
      need_setter_method
      need_getter_method
      need_value_adjusting_method

      if @setter_method
        
        listener = create_listener
        
        if listener
          master.wrappers << self
          add_listener(listener)
        end
        
      end
    end
    
    def create_listener
      ChangeAction.new(self)
    end
      
    def add_listener listener
      listener.install @component
    end
    
    def value_change value
      @controller.send(@setter_method, value)
      @master.refresh
    end
    
    def value_adjusting value
      
       if @value_adjusting_method
         @controller.send(@value_adjusting_method, value)
         @master.refresh
      end
    
    end
      
    def display new_value
      @component.value = new_value.to_ui_value
    end
    
  end
  
end