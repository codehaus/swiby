#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby'

Defaults.auto_sizing_frame = true

#-
frame {
  
  title "Implicit Default layout"
  
  content {
    button "Button 1"
    input "Name", "James"
  }
  
  visible true
  
}

#-
frame {
  
  title "Explicit Default Layout"
  
  content(:layout => :default) {
    button "Button 1"
    input "Name", "James"
  }
  
  visible true
  
}

#-
frame {
  
  title "Set FlowLayout"
  
  content(:layout => :flow) {
    button "Button 1"
    input "Name", "James"
  }
  
  visible true
  
}

#-
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

#-
frame {
  
  title "Set FlowLayout / gaps"
  
  content(:layout => :flow, :vgap => 10, :hgap => 40) {
    button "Button 1"
    input "Name", "James"
  }
  
  visible true
  
}

#-
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

#-
frame {
  
  title "Set StackedLayout / gaps"
  
  content(:layout => :stacked, :vgap => 10, :hgap => 40) {
    button "Button 1"
    input "Name", "James"
  }
  
  visible true
  
}

#-
begin
  
  frame {

    title "Raise error"

    content(12, :layout => :flow, :align => :left) {
      button "Button 1"
      input "Name", "James"
    }

    visible true

  }

  fail("ArgumentError not raised!")

rescue ArgumentError
  puts 'ArgumentError was raised, as expected'
end
