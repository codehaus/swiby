#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class FormLayoutTest < ManualTest

  manual 'Test layout' do
    
    options = {:layout => :form, :vgap => 10, :hgap => 5}

    frame {
      
      title "Form Layout Test"
      
      content(options) {

        button "Hello", :hello_but
        button "World!", :world_but
        input "Name", "<your name here>"
          
      }
      
      visible true
      
    }

  end
  
end