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
    
    class LabelRegistrar < Registrar
      
      def register
        
        super
        
        need_getter_method
        
        if @getter_method
          @master << self
        end
          
      end
      
      def display new_value
        @wrapper.text = new_value.to_s
      end
    
    end
  
    def create_registrar wrapper, master, controller, id, method_naming_provider
      LabelRegistrar.new(wrapper, master, controller, id, method_naming_provider)
    end
    
  end
  
end