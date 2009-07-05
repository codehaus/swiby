#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/text'

class FormSectionLayoutTest < ManualTest

  manual 'Section layouts...' do
    
    form {
      
      title "Section layouts..."
      
      content {
        section "::1", :layout => :flow
        input "Name", "James"  
        button "Button 1"
        command "Ok1"
        section "::2", :layout => :flow, :align => :right
        input "Code", "007"  
        input "Nickname", "Bond"
        next_row
        section "::3", :layout => :flow, :align => :left
        input "Address", "secret"  
        input "Email", "007@secret.org"      
      }
      
      visible true
      
    }

  end

  manual 'Raise error' do
    
    begin
    
      form {
        
        title "Raise error"
        
        content {
          section "::1", 12, :layout => :flow
          button "Button 1"
          input "Name", "James"  
        }
        
        
        visible true
        
      }
      
      message_box 'Exception was not raised!'
      
    rescue ArgumentError
      message_box 'ArgumentError was raised, as expected'
    end

  end
  
end