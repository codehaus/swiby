#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/button'

class HoverButtonTest < ManualTest

  manual 'Hover button w/o options' do
    
    form {
      
      title "Hover button w/o options"
      
      width 250
      height 70

      hover_button("Click me!") {
        message_box "Hello"
      }
      
      visible true
      
    }

  end
  
  manual 'Hover button in blue' do
    
    form {
      
      title "Hover button in blue"
      
      width 250
      height 70

      hover_button("Click me!", :hover_color => Color::BLUE) {
        message_box "Hello"
      }
      
      visible true
      
    }

  end
  
  manual 'Hover button w/ :action' do
    
    form {
      
      title "Hover button w/ :action"
      
      width 250
      height 70

      hover_button "Click me!", :action => proc {
        message_box "Hello"
      }
      
      visible true
      
    }
    
  end

end