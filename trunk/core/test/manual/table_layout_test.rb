#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class TableLayoutTest < ManualTest

  manual 'One row' do

    frame {
      
      title "One row"
      
      content(:layout => :table, :hgap => 5) {
      
        row
          cell
            label 'Name'
          cell
            label 'Email'
          cell :align => :center
            label "Public?"
            
      }
      
      visible true
      
    }

  end
  
  manual 'No column span' do

    frame {
      
      title "No column span"
      
      content(:layout => :table, :hgap => 5) {
      
        row
          cell
            label 'Name'
          cell
            label 'Email'
          cell :align => :center
            label "Public?"
            
        row
          cell
            input 'James'
          cell
            input 'me@james.tv'
          cell :align => :center
            check '', :public
            
        row
          cell
            input 'James Bond'
          cell
            input 'someone@universe.net'
          cell :align => :center
            check '', :public
            
      }
      
      visible true
      
    }

  end
  
  manual 'Header column span=2' do
    
    frame {
      
      title "Header column span=2"
      
      content(:layout => :table, :hgap => 5) {
        row
          cell :span => 2
            label 'Data'
          cell :align => :center
            label "Public?"
            
        row
          cell
            input 'James'
          cell
            input 'me@james.tv'
          cell :align => :center
            check '', :public
            
        row
          cell
            input 'James Bond'
          cell
            input 'someone@universe.net'
          cell :align => :center
            check '', :public
            
      }
      
      visible true
      
    }

  end
  
  manual 'Cell with several fields' do
    
    frame {
      
      title "Cell with several fields"
      
      content(:layout => :table, :hgap => 5) {
        row
          cell
            label 'Data'
          cell :align => :center
            label "Public?"
            
        row
          cell
            input 'Name', 'James'
            button 'Ok'
          cell
            label 'Yes'
            
      }
      
      visible true
      
    }

  end
  
end