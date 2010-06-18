#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/swing/timer'

require 'swiby/mvc/frame'

require 'swiby/mvc/label'
require 'swiby/mvc/check'

class MVCCheckboxesTest < ManualTest
  
  manual 'Checkboxes with controller' do

    controller = Object.new
    
    checkboxes_add_handlers controller
        
    ViewDefinition.bind_controller checkboxes_create_view, controller
    
  end

  manual 'Checkboxes with view only' do

    view = checkboxes_create_view
    
    checkboxes_add_handlers view

    ViewDefinition.bind_controller view
    
  end
  
end

def checkboxes_create_view
  
  form {
    
    title 'Checkboxes'
    
    width 400
    height 350
    
    section 'Results'
      label :name => :results
    
    next_row
    section 'Disabled checkboxes'
      check "With a name", :name => :with_a_name
      check "By controller", :name => :disabled_by_controller
    
    section 'Enabled checkboxes'
      check "Without name"
      check "By controller", :name => :enabled_by_controller
    
    next_row
    section 'Active checkboxes'
      check "Click me!", :name => :click_me
      check "Error! You should not see this text!", :name => :change_text
        
    visible true
    
  }
  
end

def checkboxes_add_handlers o
  
  class << o
    
    bindable :message
    attr_accessor :message
    
    def results
      @message
    end
    
    def disabled_by_controller
    end
    def may_disabled_by_controller?
      false
    end
    
    def enabled_by_controller
    end
    
    def click_me
      
      self.message = "<html>You clicked the 'Click me!' checkbox<br>Should clear automatically."
      
      after(1000) do
        self.message = ""
      end
      
    end
    
    def change_text
      case @some_text
        when 'Click me to'
          @some_text = 'change text'
        when 'change text'
          @some_text = 'each time'
        when 'each time'
          @some_text = 'Click me to'
      end
    end
    def change_text_command_text
      @some_text = 'Click me to' unless @some_text
      @some_text
    end
    
  end
    
end
