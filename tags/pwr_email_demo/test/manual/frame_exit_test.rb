#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/text'

class FrameExitTest < ManualTest

  block = proc {
    
    content {
      north
        button "Button 1"
        
      center
        input "Name", "James"
    }
    
    visible true
    
  }

  manual 'Should hide on close' do
    
    frame {
      
      title "Should hide on close"
      
      height 100
      width 250
      
      hide_on_close
      
      self.instance_eval(&block)
      
    }

  end
  
  manual 'Should dispose on close' do
    
    frame {
      
      title "Should dispose on close"
      
      height 100
      width 250
      
      dispose_on_close
      
      self.instance_eval(&block)
      
    }

  end
  
end