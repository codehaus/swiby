#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/combo'

module Swiby
  
  class ComboBox
        
    class ComboRegistrar < Registrar
      
      include SelectableComponendBehavior
      
      def create_listener
        ClickAction.new(self)
      end
      
      def handles_actions?
        !@setter_method.nil? or !@value_index_setter_method.nil?
      end
      
    end
    
    def create_registrar wrapper, master, controller, id, method_naming_provider
      ComboRegistrar.new(wrapper, master, controller, id, method_naming_provider)
    end

    def registration_done *registrars
      self.enabled = registrars.any? {|reg| reg.handles_actions?}
    end
    
  end
  
end