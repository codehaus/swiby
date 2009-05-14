#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/text'

class FrameWithPanelTest < ManualTest

  manual 'frame with centerd panel (default layouts)' do
    
    frame {
      
      title 'frame with centerd panel (default layouts)'

      width 500
      height 150
      
      content {
        
        north
          input "Joe"
        south
          button "Yes"

        center
          panel {
            content {
              input "Address", "5th street"
              button "search"
            }
          }
          
      }

      visible true
      
    }
    
  end

  manual 'frame with centerd panel (with border layout)' do
    
    frame {
      
      title 'frame with centerd panel (with border layout)'

      width 500
      height 150
      
      content {
        
        north
          input "Joe"
        south
          button "Yes"

        center
          panel {
            content(:layout => :border) {
              center
                input "Address", "5th street"
              south
                button "search"
            }
          }
          
      }

      visible true
      
    }

  end
  
end