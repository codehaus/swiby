#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc/frame'
require 'swiby/mvc/label'
require 'swiby/mvc/slider'

class MVCSliderTest < ManualTest
  
  manual 'Sliders with controller' do

    controller = Object.new
    
    sliders_add_handlers controller
        
    ViewDefinition.bind_controller sliders_create_view, controller
    
  end

  manual 'Sliders with view only' do

    view = sliders_create_view
    
    sliders_add_handlers view

    ViewDefinition.bind_controller view
    
  end
  
end

def sliders_create_view
  
  form {
    
    title 'Sliders'
    
    width 600
    height 380
    
    section 'Disabled sliders'
      slider "With a name", :with_a_name
      slider "By controller", :disabled_by_controller
    
    section 'Enabled sliders'
      slider "Without name"
      slider "By controller", :name => :enabled_by_controller
    
    next_row
    section 'Displaying while dragging, 0-40 initialized to 23'
      slider :horizontal, 0, 40, :name => :slider1
      label "", :name => :value1

    next_row
    section 'Displaying value when adjustment is over'
      slider :horizontal, :name => :slider2
      label "", :name => :value2
    
    visible true
    
  }
  
end

def sliders_add_handlers o
  
  class << o
    
    def disabled_by_controller= val
    end
    def may_disabled_by_controller?
      false
    end
    
    def enabled_by_controller= val
    end
    
    def slider1
      @slider1_value1 = 23 unless @slider1_value1
      @slider1_value1
    end
    def adjusting_slider1 val
      @slider1_value1 = val
    end
    def value1
      "Current value is #{@slider1_value1}"
    end
    
    def slider2
      @slider2_value2 = 0 unless @slider2_value2
      @slider2_value2
    end
    def slider2= val
      @slider2_value2 = val
    end
    def value2
      "Current value is #{@slider2_value2}"
    end
    
  end
  
end
