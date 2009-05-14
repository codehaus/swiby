#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/text'

class FormInnerLayoutTest < ManualTest
  
  form_content = proc {
      section "::1"
        input "Name", "James" 
        button "Button 1"
      section "::2"
        input "Code", "007"  
        input "Nickname", "Bond"
      next_row
      section "::3"
        input "Address", "secret"  
        input "Email", "007@secret.org"  
  }

  manual 'Implicit Default layout' do

    form {
      
      title "Implicit Default layout"
      
      width 360
      height 220
      
      content(&form_content)
      
      visible true
      
    }
    
  end

  manual 'Explicit Default Layout' do
    
    form {
      
      title "Explicit Default Layout"
      
      width 360
      height 220
      
      content(:layout => :default, &form_content)
      
      visible true
      
    }
    
  end

  manual 'Set FlowLayout' do
    
    form {
      
      title "Set FlowLayout"
      
      width 500
      height 220
      
      content(:layout => :flow, &form_content)
      
      visible true
      
    }
    
  end

  manual 'Set FlowLayout / all alignments' do
    
    [:left, :center, :right].each do |align|
      form {

        title "Set FlowLayout / #{align} alignment"
      
        width 500
        height 200

        content(:layout => :flow, :align => align, &form_content)

        visible true

      }
    end
    
  end

  manual 'Set FlowLayout / gaps' do
    
    form {
      
      title "Set FlowLayout / gaps"
      
      width 500
      height 200
      
      content(:layout => :flow, :vgap => 10, :hgap => 40, &form_content)
      
      visible true
      
    }
    
  end

  manual 'Raise error' do
    
    begin
    
      form {
        
        title "Raise error"
        
        content(12, :layout => :flow, :align => :left, &form_content)
        
        visible true
        
      }
      
      message_box 'Exception was not raised!'
      
    rescue ArgumentError
      message_box 'ArgumentError was raised, as expected'
    end

  end

end