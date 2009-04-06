#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class BorderLayoutTest < ManualTest
  
  manual 'Test implicit default layout' do

    frame {
      
      title "Implicit Default layout"
      
      content {
        north
          label "Here is north"
        south
          button "South button"
        center
          button "Center button"
        east
          button "east"
        west
          button "west"
      }
      
      visible true
      
    }

  end

end
