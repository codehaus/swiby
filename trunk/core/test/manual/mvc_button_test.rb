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
require 'swiby/mvc/button'
require 'swiby/mvc/file_button'

class MVCButtonsTest < ManualTest
  
  manual 'Buttons with controller' do

    controller = Object.new
    
    buttons_add_handlers controller
        
    ViewDefinition.bind_controller buttons_create_view, controller
    
  end

  manual 'Buttons with view only' do

    view = buttons_create_view
    
    buttons_add_handlers view

    ViewDefinition.bind_controller view
    
  end
  
end

def buttons_create_view
  
  form {
    
    title 'Buttons'
    
    width 400
    height 350
    
    section 'Results'
      label :name => :results
    
    next_row
    section 'Disabled buttons'
      button "With a name", :name => :with_a_name
      button "By controller", :name => :disabled_by_controller
    
    section 'Enabled buttons'
      button "Without name"
      button "By controller", :name => :enabled_by_controller
    
    next_row
    section 'Active buttons'
      button "Click me!", :name => :click_me
      button "Error! You should not see this text!", :name => :change_text
    
    next_row
    section 'File buttons (*.txt, *.html and *.rb)'
      open_file("open", :open) { |extensions|
        extensions.add 'HTML files (*.htm, *.html)', 'htm', 'html'
        extensions.add 'Ruby scripts (*.rb)', 'rb'
        extensions.add 'Text files (*.txt)', 'txt'
      }
      save_file("save", :save) { |extensions|
        extensions.add 'HTML files (*.htm, *.html)', 'htm', 'html'
        extensions.add 'Ruby scripts (*.rb)', 'rb'
        extensions.add 'Text files (*.txt)', 'txt'
      }
    
    visible true
    
  }
  
end

def buttons_add_handlers o
  
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
      
      self.message = "<html>You clicked the 'Click me!' button<br>Should clear automatically."
      
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
  
    def open selected_file
    end
    
    def save selected_file
    end
    
  end
    
end
