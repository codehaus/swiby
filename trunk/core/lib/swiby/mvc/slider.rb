#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/slider'
require 'swiby/util/developer'

module Swiby

  class MethodNamingProvider
    
    def value_adjusting_method(id)
      "adjusting_#{id}".to_sym
    end
    
  end
  
  class Slider
    
    class SliderRegistrar < Registrar
      
      def register
        
        super
        
        need_setter_method
        need_getter_method
        need_value_adjusting_method

        if @setter_method or @value_adjusting_method
          
          listener = create_listener
          
          if listener
            @master << self
            add_listener(listener)
          end
          
        end
      end
      
      def create_listener
        ChangeAction.new(self)
      end
        
      def add_listener listener
        listener.install @component
      end
      
      def value_change value
        
        if @setter_method
          @controller.send(@setter_method, value)
          @master.refresh
        elsif @value_adjusting_method
          @controller.send(@value_adjusting_method, value)
          @master.refresh
        end
      
      end
      
      def value_adjusting value
        
        if @value_adjusting_method
          @controller.send(@value_adjusting_method, value)
          @master.refresh
        end
      
      end
        
      def display new_value
        @wrapper.value = new_value.to_i
      end
    
      def handles_actions?
        !@setter_method.nil? or !@value_adjusting_method.nil?
      end
    
    end
    
    def create_registrar wrapper, master, controller, id, method_naming_provider
      SliderRegistrar.new wrapper, master, controller, id, method_naming_provider
    end

    def registration_done *registrars
      @component.enabled = registrars.any? {|reg| reg.handles_actions?}
    end
    
  end
  
end