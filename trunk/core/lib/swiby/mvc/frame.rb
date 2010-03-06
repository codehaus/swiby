#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/frame'

module Swiby
  
  class Frame
    
    class FrameRegistrar < Registrar
      
      # use 'on_window_close' has MVC handler instead of 'on_close' to
      # avoid conflicting with 'on_close' when the view it self
      # is used as controller
      def register
      
        if @controller.respond_to?(:on_window_close)
          @wrapper.on_close { @controller.send(:on_window_close) }
        end
        
      end
      
      def enable_disable
      end
      
      def update_display
      end
      
    end
    
    def create_registrar wrapper, master, controller, id, method_naming_provider
      FrameRegistrar.new(wrapper, master, controller, id, method_naming_provider)
    end
    
    def bindable *args
      
      (class << self; self; end).module_eval do
        bindable *args
      end
      
    end
    
    def attr_accessor *args
      
      (class << self; self; end).module_eval do
        attr_accessor *args
      end
      
    end
    
  end
  
end