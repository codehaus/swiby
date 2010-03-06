#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/mvc/combo'
require 'swiby/component/radio_button'

module Swiby

  class RadioGroup
    
    class RadioGroupRegistrar < ComboRegistrar
      
      def add_listener listener
        @wrapper.add_action_listener listener
      end
      
    end
    
    def create_registrar wrapper, master, controller, id, method_naming_provider
      RadioGroupRegistrar.new(wrapper, master, controller, id, method_naming_provider)
    end

    def registration_done *registrars
      self.enabled = registrars.any? {|reg| reg.handles_actions?}
    end
        
  end
  
end
