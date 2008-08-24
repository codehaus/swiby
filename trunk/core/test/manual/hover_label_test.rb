#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class HoverLabelTest < ManualTest

  manual 'Hover label w/o options' do
    
    form {
      
      title "Hover label w/o options"
      
      width 250
      height 70

      hover_label("Click me!")  {
        message_box "Hello"
      }
      
      visible true
      
    }

  end
  
  manual 'Hover label in blue' do
    
    form {
      
      title "Hover label in blue"
      
      width 250
      height 70

      hover_label("Click me!", :hover_color => AWT::Color::BLUE)  {
        message_box "Hello"
      }
      
      visible true
      
    }

  end
  
  manual 'Hover label w/ :action' do
    
    form {
      
      title "Hover label w/ :action"
      
      width 250
      height 70

      hover_label "Click me!", :action => proc {
        message_box "Hello"
      }
      
      visible true
      
    }
    
  end

end