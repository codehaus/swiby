#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/form'

#-
form {
  
  title "Section layouts..."
  
  content {
    section "::1", :layout => :flow
    button "Button 1"
    input "Name", "James"  
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


#-
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
rescue ArgumentError
  puts 'ArgumentError was raised, as expected'
end
