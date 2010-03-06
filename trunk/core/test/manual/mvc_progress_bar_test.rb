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
require 'swiby/mvc/progress_bar'

class MVCProgressBarTest < ManualTest
  
  manual 'Buttons with controller' do

    controller = Object.new
    
    progressbar_add_handlers controller
        
    ViewDefinition.bind_controller progressbar_create_view, controller
    
  end

  manual 'Buttons with view only' do

    view = progressbar_create_view
    
    progressbar_add_handlers view

    ViewDefinition.bind_controller view
    
  end
  
end

def progressbar_create_view
  
  form {
    
    title 'Progress bars'
    
    width 400
    height 350
    
    section 'Simple starting at 50% (0-100)'
      progress :horizontal, :name => :simple

    next_row
    section 'Default value display starting at 20% (10-70)'
      progress :horizontal, 10, 70, :name => :default_string
      swing { |comp|
        comp.string_painted = true
      }
        
    next_row
    section 'Custom value display starting at 0% (30-120)'
      progress :horizontal, 30, 120, :name => :custom_string
    
    visible true
    
  }
  
end

def progressbar_add_handlers o
  
  class << o
    
    bindable :simple_value
    
    attr_accessor :simple_value
    attr_accessor :custom_value
    attr_accessor :default_value
    
    attr_accessor :simple
    attr_accessor :default_string
    attr_accessor :custom_string
    
    def formated_custom_string
      "Value = #{@custom_value}"
    end
    
    def on_window_close
      @timer.stop if @timer
    end
    
    def start_timer
      @timer = every(300) do
        self.simple_value = (self.simple_value + 1).modulo(100)
        self.custom_value = 30 + (self.custom_value - 30 + 1).modulo(90)
        self.default_value = 10 + (self.default_value - 10 + 1).modulo(60)
      end
    end
    
    def simple
      @simple_value
    end
    def default_string
      @default_value
    end
    def custom_string
      @custom_value
    end
    
  end
    
  o.simple_value = 50
  o.custom_value = 30
  o.default_value = 22
  
  o.start_timer
  
end
