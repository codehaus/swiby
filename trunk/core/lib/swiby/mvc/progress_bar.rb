#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/progress_bar'

module Swiby

  class MethodNamingProvider
    
    def formated_value_method(id)
      "formated_#{id}".to_sym
    end
    
  end

  class Progress
    
    class ProgressRegistrar < Registrar
        
      def register
        
        super
        
        need_getter_method
        need_formated_value_method
        
        @master << self if @getter_method
          
      end
        
      def display new_value
        
        @wrapper.value = new_value.to_i
        
        if @formated_value_method
          text = @controller.send(@formated_value_method)
          @component.string = text
          @component.string_painted = true
       end
        
      end
      
    end
  
    def create_registrar wrapper, master, controller, id, method_naming_provider
      ProgressRegistrar.new(wrapper, master, controller, id, method_naming_provider)
    end
    
  end
  
end