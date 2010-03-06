#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/button'

module Swiby

  class MethodNamingProvider
    
    def command_text(id)
      "#{id}_command_text".to_sym
    end
    
  end

  class Button
    
    class ButtonRegistrar < Registrar
      
      def register
        
        super
        
        need_command_text
        need_action_method

        if @action_method
          
          listener = create_listener
          
          if listener
            @master << self
            add_listener(listener)
          end
        
        end

      end
      
      def create_listener
        ClickAction.new(self)
      end
        
      def add_listener listener
        listener.install @component
      end
      
      def update_display
        
        if @command_text
          
          text = @controller.send(@command_text)
          
          @wrapper.text = text
            
        end
        
      end
      
      def execute_action
        
        @controller.send @action_method
        
        @master.refresh
        
      end
      
      def handles_actions?
        !@action_method.nil?
      end
    
    end
    
    def create_registrar wrapper, master, controller, id, method_naming_provider
      ButtonRegistrar.new(wrapper, master, controller, id, method_naming_provider)
    end

    def registration_done *registrars
      @component.enabled = registrars.any? {|reg| reg.handles_actions?}
    end
    
    def click
      @component.doClick
    end

    def enabled
      @component.enabled
    end

  end
  
end