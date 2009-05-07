#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/label'

module Swiby
  
  class SimpleLabel
    
    def register master, controller, id, method_naming_provider
      super
      
      need_getter_method
      
      if @getter_method
        master.wrappers << self
      end
        
    end
    
    def display new_value
      @component.text = new_value.to_s
    end
    
  end
  
end