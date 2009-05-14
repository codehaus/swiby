#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/text'

module Swiby

  module TextInputMVCExtensions
    
    INPUT_CONFIRM_LISTENER_FACTORIES = {
      :command => lambda {|comp| ClickAction.new(comp)},
      :focus_lost =>  lambda {|comp| FocusAction.new(comp)}
    }
  
    def register master, controller, id, method_naming_provider
      
      super
      
      need_setter_method
      need_getter_method
      
      added_self = false

      if @setter_method
        
        listener = create_listener
        
        if listener
          added_self = true
          master.wrappers << self
          add_listener(listener)
        end
        
      end
      
      if @getter_method and not added_self
        master.wrappers << self
      end
        
    end
    
    def create_listener
      
      confirm_type = Swiby.input_confirm_on
      
      factory = INPUT_CONFIRM_LISTENER_FACTORIES[confirm_type]
      
      raise "Input confirm type not supported: #{confirm_type}" unless factory
      
      factory.call(self)
      
    end
      
    def add_listener listener
      listener.install @component
    end
    
    def display new_value
      self.value = new_value
    end
    
    def execute_action
      @controller.send @setter_method, value
      @master.refresh
    end
    
  end

  class TextField
    include TextInputMVCExtensions
  end
  
  class PasswordField
    include TextInputMVCExtensions
  end
  
end