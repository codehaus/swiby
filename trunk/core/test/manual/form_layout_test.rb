#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/text'

class FormLayoutTest < ManualTest

  manual 'Test layout' do
    
    options = {:layout => :form, :vgap => 10, :hgap => 5}

    frame {
      
      title "Form Layout Test"
      
      content(options) {

        input "Name", "<your name here>"
          
        button "Hello", :hello_but
        button "World!", :world_but
        
        command "Ok"
        
      }
      
      visible true
      
    }

  end

  manual "Several buttons/commands" do
    
    form {
      
      title 'Now, with MigLayout buttons must be at the end...'
      
      content {
        section "::1"
          input "Code", "007"
          input "First name", "James"
          input "Surname", "Bond"
          button "But 1"
          button "Button 2"
          command "Ok"
          command "Cancel"
      }
      
      visible true
      
    }

  end

  manual 'Fields without labels' do
    
    form {
      
      content {
        section "::1"
        input "Name", "James"  
        text  "Secret"  
      }
      
      visible true
      
    }

  end

  manual 'Test no labels does not add unecessary hgaps' do
    
    form {
      
      content {
        section "::1"
        text "James"  
        text  "Secret"  
      }
      
      visible true
      
    }

  end
  
end