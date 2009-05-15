#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby'

class Class
  
  def bindable *fields
    
    class << self 
      
      def has_bindable?
        @bindable_fields and @bindable_fields.size > 0
      end
      
      def bindable_fields
        @bindable_fields = [] unless @bindable_fields
        @bindable_fields
      end
      
    end
    
    fields.each do |field|
      self.bindable_fields << fields
    end
    
  end
  
end

module Swiby

  class MethodNamingProvider
    
    def readonly_check_method(id)
      "may_change_#{id}?".to_sym
    end
    
    def enabled_state_check_method(id)
      "may_#{id}?".to_sym
    end
  
    def action_method(id)
      id.to_sym
    end
    
    def selection_handler_method(id)
      "current_#{id}=".to_sym
    end
  
    def getter_method(id)
      id.to_sym
    end
    
    def setter_method(id)
      "#{id}=".to_sym
    end
  
    def value_changed_method(id)
      "#{id}_changed?".to_sym
    end
    
    def validator_method(id)
      "#{id}_valid?".to_sym
    end
    
  end
  
  @confirm_method = :focus_lost
  @default_method_naming_provider = MethodNamingProvider.new
  
  def self.default_method_naming_provider
    @default_method_naming_provider
  end
  
  def self.default_method_naming_provider= method_naming_provider
    @default_method_naming_provider = method_naming_provider
  end
  
  def self.input_confirm_on
    @confirm_method
  end
  
  def self.input_confirm_on= confirm_method
    @confirm_method = confirm_method
  end
  
  module ActionHandler
    
    def initialize wrapper
      @wrapper = wrapper
    end
    
  end
  
  class ChangeAction
    include ActionHandler
    include javax.swing.event.ChangeListener
    
    def stateChanged(ev)
      if ev.source.getValueIsAdjusting
        @wrapper.value_adjusting ev.source.value
      else
        @wrapper.value_change ev.source.value
      end
    end
    
    def install component
      component.add_change_listener self
    end
    
  end
  
  class ClickAction
    include ActionHandler  
    include java.awt.event.ActionListener
    
    def actionPerformed(ev)
      @wrapper.execute_action
    end

    def install component
      component.add_action_listener self
    end
    
  end
  
  class FocusAction
    include ActionHandler  

    def focusGained(ev)
    end
  
    def focusLost(ev) 
      @wrapper.execute_action
    end
  
    def install component
      component.addFocusListener(self)
    end
    
  end
  
  class SelectionAction
    include ActionHandler
    include javax.swing.event.ListSelectionListener
    
    def valueChanged(e)
      @wrapper.selection_changed
    end
  
    def install component
      component.getSelectionModel().addListSelectionListener(self)
    end
    
  end
  
  class MasterController
    
    attr_reader :wrappers
    
    def initialize
      @wrappers = []
    end
    
    def refresh
      @wrappers.each do |wrapper|
        wrapper.enable_disable
      end
    end
    
  end
  
  class Views
    
    def self.[] name
      ViewDefinition.definitions[name]
    end
    
    def exist? name
      ViewDefinition.definitions.has_key?(name)
    end
    
  end
  
  class ViewDefinition
    
    def initialize &def_block
      @def_block = def_block
    end
    
    def self.definitions
      @view_definitions = {} unless @view_definitions
      @view_definitions
    end
    
    def instantiate controller, method_naming_provider = nil
      
      method_naming_provider = Swiby.default_method_naming_provider unless method_naming_provider
      
      window_wrapper = @def_block.call
      window = window_wrapper.java_component
      
      master = MasterController.new
      
      register_components window_wrapper, master, controller, method_naming_provider
      
      if controller.class.respond_to?(:has_bindable?) and controller.class.has_bindable?
        
        controller.class.bindable_fields.each do |field|
          
          setter = method_naming_provider.setter_method(field)
          
          if controller.respond_to?(setter)
            
            orig = "orig_#{setter}".to_sym
            
            code =<<CODE
            class << self
              alias :#{orig} :#{setter}
              
              def #{setter} new_value
                self.send :#{orig}, new_value
                @master.refresh
              end
              
            end
CODE
          
            controller.instance_eval code
            
            def controller.master= master
              @master = master
            end
          
            controller.master = master
          
          end
        
        end
      
      end
      
      controller.instance_variable_set :@window, window_wrapper
      
      master.refresh
      
      window.visible = true
      
      window_wrapper
      
    end

    private
    
    def register_components parent, master, controller, method_naming_provider
      
      parent.each do |wrapper|

        id = wrapper.name
        
        if id
          wrapper.register(master, controller, id, method_naming_provider)
        end

        if wrapper.respond_to?(:each)
          register_components wrapper, master, controller, method_naming_provider
        end
        
      end
      
    end
    
  end
  
  # define a view, registers it with the given name for later retrieval
  # returns the view definition
  def self.define_view name = nil, &definition
    view_def = ViewDefinition.new(&definition)
    ViewDefinition.definitions[name] = view_def if name
    view_def
  end
  
  class SwingBase
    
    attr_reader :component, :master

    def initialize component
      @component = component
      @master = nil
    end
  
    def register master, controller, id, method_naming_provider
      @id = id
      @master = master
      @controller = controller
      @method_naming_provider = method_naming_provider
      
      need_enabled_state_check_method
      need_readonly_check_method
      need_value_changed_method
    end
    
    def enable_disable
      
      if @getter_method
        
        read_value = true
        read_value = @controller.send(@value_changed_method) if @value_changed_method
        
        if read_value
          new_value = @controller.send(@getter_method)
          display new_value
        end
      
      end
      
      if @enabled_state_check_method
        @component.enabled = @controller.send(@enabled_state_check_method) == true
      end
      
      if @readonly_check_method
        @component.editable = @controller.send(@readonly_check_method) == true
      end
      
    end
    
    def method_missing(meth, *args)

      raise NoMethodError.new("undefined method `#{meth}' for #{self}", meth, args) unless meth.to_s =~ /^need_(.*)/
      
      name = $1
      
      method = @method_naming_provider.send(name, @id)
      method = nil unless @controller.respond_to?(method)
      
      instance_variable_set("@#{name}".to_sym, method)
      
    end
    
  end
      
end