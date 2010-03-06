#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc'
require 'swiby/component/table'

module Swiby
  
  class Table
    
    class TableRegistrar < Registrar
      
      include SelectableComponendBehavior
    
      def selection_changed
        
        index = @component.getSelectedRow
        
        if @setter_method
          @controller.send(@setter_method, index)
        else
          @controller.send(@value_index_setter_method, index)
        end
      
        @master.refresh
        
      end
      
      def handles_actions?
        !@setter_method.nil? or !@value_index_setter_method.nil?
      end
      
    end
    
    def create_registrar wrapper, master, controller, id, method_naming_provider
      TableRegistrar.new(wrapper, master, controller, id, method_naming_provider)
    end

    def registration_done *registrars      
        
      #TODO improve making table read-only
      @component.setDefaultEditor(@component.getColumnClass(0), nil) if @component.getColumnCount() > 0
      
      self.enabled = registrars.any? {|reg| reg.handles_actions?}
      
    end
 
  end
  
end