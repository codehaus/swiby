#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class FrameLayoutTest < ManualTest

  manual 'Implicit Default layout' do
    
    frame {
      
      title "Implicit Default layout"
      
      content {
        button "Button 1"
        input "Name", "James"
      }
      
      visible true
      
    }

  end

  manual 'Explicit Default Layout' do
    
    frame {
      
      title "Explicit Default Layout"
      
      content(:layout => :default) {
        button "Button 1"
        input "Name", "James"
      }
      
      visible true
      
    }

  end

  manual 'Set FlowLayout' do
    
    frame {
      
      title "Set FlowLayout"
      
      content(:layout => :flow) {
        button "Button 1"
        input "Name", "James"
      }
      
      visible true
      
    }

  end

  manual 'Set FlowLayout / all alignments' do
    
    [:left, :center, :right].each do |align|
      frame {

        title "Set FlowLayout / #{align} alignment"

        content(:layout => :flow, :align => align) {
          button "Button 1"
          input "Name", "James"
        }

        visible true

      }
    end

  end

  manual 'Set FlowLayout / gaps' do
    
    frame {
      
      title "Set FlowLayout / gaps"
      
      content(:layout => :flow, :vgap => 10, :hgap => 40) {
        button "Button 1"
        input "Name", "James"
      }
      
      visible true
      
    }

  end

  manual 'Set StackedLayout / all alignments' do
    
    [:left, :center, :right].each do |align|
      frame {

        title "Set StackedLayout / #{align} alignment"

        content(:layout => :stacked, :align => align) {
          button "Button 1"
          input "Name", "James"
        }

        visible true

      }
    end

  end

  manual 'Set StackedLayout / gaps' do
    
    frame {
      
      title "Set StackedLayout / gaps"
      
      content(:layout => :stacked, :vgap => 10, :hgap => 40) {
        button "Button 1"
        input "Name", "James"
      }
      
      visible true
      
    }

  end

  manual 'Raise error' do
    
    begin
      
      frame {

        title "Raise error"

        content(12, :layout => :flow, :align => :left) {
          button "Button 1"
          input "Name", "James"
        }

        visible true

      }

      message_box 'ArgumentError not raised!'
        
    rescue ArgumentError
      message_box 'ArgumentError was raised, as expected'
    end

  end
  
end