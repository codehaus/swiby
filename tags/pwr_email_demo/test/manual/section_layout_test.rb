#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class SectionLayoutTest < ManualTest
  
  manual 'Test defaults to preferred size' do

    form {
      
      content {
        section "Title 1"
        next_row
        section "Title 2"
        next_row
        section "Title 3"
      }
      
      visible true
      
    }
    
  end
  
  
  manual 'Test use minimum size of children' do

    form {
      
      content {
        section "Title 1"
          button "1"
        next_row
        section "Title 2"
          button "2"
        next_row
        section "Title 3"
          button "3"
      }
      
      visible true
      
    }
    
  end
  
  manual 'Test percentatge distibution' do

    form {
      
      content {
        section "80 %", :expand => 80
        next_row
        section "20 %", :expand => 20
      }
      
      visible true
      
    }
    
  end
  
  manual 'Test expands by row' do

    form {
      
      content {
        section "80 %", :expand => 80
        section "Another 80 % (same row)", :expand => 80
        next_row
        section "20 %", :expand => 20
      }
      
      visible true
      
    }
    
  end
  
  manual 'Test bigger by row wins' do

    form {
      
      content {
        section "40 %", :expand => 40
        section "80 % (same row)", :expand => 80
        next_row
        section "20 %", :expand => 20
      }
      
      visible true
      
    }
    
  end
  
end
