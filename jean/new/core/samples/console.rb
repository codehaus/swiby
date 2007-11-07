#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/form'

def open_console run_context
  
  form do
    
    title "Console"
    
    editor 400, 300
    
    button "Execute" do
      run_context.instance_eval(context[1].text)
    end
    button "Close" do
      close
    end
    
    visible true
    
  end
  
end