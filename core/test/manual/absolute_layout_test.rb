#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout/absolute'

require 'swiby/component/text'
require 'swiby/component/label'

class AbsoluteLayoutTest < ManualTest
  
  manual 'Test absolute layout' do
    
    options = {:layout => :absolute, :vgap => 10, :hgap => 5}

    frame {
      
      title "Absolute Layout Test"
      
      content(options) {
        
        at [10, 10]
          button "Hello", :hello_but
          
        at [30, 50]
          button "World!", :world_but
          
        at [0, 5], relative_to(:world_but, :align, :below)
          label "Name:", :the_label
        at [10, 0], relative_to(:the_label, :right, :align)
          input "<your name here>"
        
        at [0, 0], relative_to(:hello_but, :left, :above)
          label "1"
        at [0, 0], relative_to(:world_but, :left, :align)
          label "2"
          
        at [0, 0], relative_to(:parent, :align_right_edge, :align)
          label 'top-right'
          
        at [0, 0], relative_to(:parent, :align, :align_bottom_edge)
          label 'bottom-left'
          
        at [0, 0], relative_to(:parent, :align_right_edge, :align_bottom_edge)
          label 'bottom-right'
        
      }
      
      visible true
      
    }
    
  end
  
end
