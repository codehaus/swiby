#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/text'

class PasswordTest < ManualTest

  manual 'Password input' do

    form {
      
      title 'Login...'

      width 200
      height 160
      
      content {
        section 'Click OK to check input'
          input "Login:", "", :name => :login
          password "Password:", "", :name => :pwd
        
          button('Ok') {
            message_box "Login is #{context[:login].value}/#{context[:pwd].value}"
          }
         
      }
      
      visible true
      
    }

  end
  
  
end