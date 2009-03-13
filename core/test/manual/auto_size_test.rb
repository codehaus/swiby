#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/text'

class AutosizeTest < ManualTest

  content_builder = proc {
    section 'Enter your login and password'
      input "Login:", ""
      password "Password:", ""
    
      button 'Ok'
     
  }
      
  def setup
    Defaults.auto_sizing_frame = false
  end
  
  manual 'Full autosize' do

    form {
      
      title 'Login...'

      autosize
      
      content &content_builder
      
      visible true
      
    }
    
  end
  
  manual 'width + autosize' do

    form {
      
      title 'Login...'

      autosize
      width 200
      
      content &content_builder
      
      visible true
      
    }

  end
  
  manual 'height + autosize' do

    form {
      
      title 'Login...'

      autosize
      height 180
      
      content &content_builder
      
      visible true
      
    }
    
  end
  
  manual 'width and height + autosize' do

    form {
      
      title 'Login...'

      autosize
      
      width 200
      height 180
      
      content &content_builder
      
      visible true
      
    }
  
  end
  
  manual 'width + Default autosize' do

    Defaults.auto_sizing_frame = true
    
    form {
      
      title 'Login...'
      
      width 200
      
      content &content_builder
      
      visible true
      
    }
  
  end

  manual 'disable autosize + Default autosize' do

    Defaults.auto_sizing_frame = true
    
    form {
      
      title 'Login...'
      
      autosize false
      
      content &content_builder
      
      visible true
      
    }
  
  end
  
  manual 'Modal dialog - width + autosize' do

    dialog(nil) {
      
      title 'Login...'
      
      autosize
      width 200
      
      content &content_builder
      
      visible true
      
    }
  
  end

end