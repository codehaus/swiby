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
    
    def self.has_bindable?
      @bindable_fields and @bindable_fields.size > 0
    end
    
    def self.bindable_fields
      @bindable_fields = [] unless @bindable_fields
      @bindable_fields
    end

    fields.each do |field|
      self.bindable_fields << field unless self.bindable_fields.include?(field)
    end
    
  end
  
end

module Swiby

  class Registrar
    
    attr_writer :added_to_master
    
    def initialize wrapper, master, controller, id, method_naming_provider
      
      @id = id
      @master = master
      @wrapper = wrapper
      @controller = controller
      @method_naming_provider = method_naming_provider
      
      @component = wrapper.java_component(true)
      
      @added_to_master = false
      
    end
    
    def added_to_master?
      @added_to_master
    end
    
    def register
      
      need_enabled_state_check_method
      need_visible_state_check_method
      need_readonly_check_method
      need_value_changed_method
      
    end
    
    def enable_disable
      
      update_display
      
      if @enabled_state_check_method
        @wrapper.enabled = @controller.send(@enabled_state_check_method) == true
      end
      
      if @readonly_check_method
        @component.editable = @controller.send(@readonly_check_method) == true
      end
      
      if @visible_state_check_method
        @component.visible = @controller.send(@visible_state_check_method) == true
      end
      
    end
    
    def update_display
      
      if @getter_method
        
        read_value = true
        read_value = @controller.send(@value_changed_method) if @value_changed_method
        
        if read_value
          new_value = @controller.send(@getter_method)
          display new_value
        end
      
      end
      
    end
    
    def method_missing(meth, *args)

      super unless meth.to_s =~ /^need_(.*)/
      
      name = $1
      
      method = @method_naming_provider.send(name, @id)
      method = nil unless @controller.respond_to?(method)
      
      instance_variable_set("@#{name}".to_sym, method)
      
    end
    
  end
  
  class MethodNamingProvider
    
    def readonly_check_method(id)
      "may_change_#{id}?".to_sym
    end
    
    def enabled_state_check_method(id)
      "may_#{id}?".to_sym
    end
    
    def visible_state_check_method(id)
      "show_#{id}?".to_sym
    end
  
    def action_method(id)
      id.to_sym
    end
    
    def getter_method(id)
      id.to_sym
    end
    
    def setter_method(id)
      "#{id}=".to_sym
    end
  
    def selected_indexes_method(id)
      "selected_#{id}=".to_sym
    end
    
    def value_index_setter_method(id)
      "#{id}_index=".to_sym
    end
  
    def value_changed_method(id)
      "#{id}_changed?".to_sym
    end

    def remove_item_method(id)
      "remove_#{id}".to_sym
    end
    
    def list_method(id)
      "list_of_#{id}".to_sym
    end

    def list_changed_method(id)
      "list_of_#{id}_changed?".to_sym
    end
    
    def validator_method(id)
      "#{id}_valid?".to_sym
    end
    
  end
  
  module SelectableComponendBehavior
    
    def register
      
      super
      
      need_getter_method
      need_setter_method
      
      need_list_method
      need_list_changed_method
      need_value_index_setter_method
      
      if @getter_method
        @master << self
      end

      if @setter_method or @value_index_setter_method
        add_listener create_listener
        @master << self
      end
      
    end
      
    def create_listener
      SelectionAction.new(self)
    end
    
    def add_listener listener
      listener.install @component
    end
    
    def enable_disable
      
      if @list_method
        
        changed = false
        changed = @controller.send(@list_changed_method) if @list_changed_method
        
        if changed
          new_list = @controller.send(@list_method)
          change_list new_list
        end
        
      end
      
      super
      
    end
    
    def display new_value
      
      if @selected_indexes_method or @value_index_setter_method
        @wrapper.selection = new_value
      else
        @wrapper.value = new_value
      end
      
    end
    
    def change_list new_content
      @wrapper.content = new_content
    end
      
    def execute_action
      
      if @value_index_setter_method
        @controller.send(@value_index_setter_method, @wrapper.selection)
      else
        @controller.send(@setter_method, @wrapper.value)
      end
    
      @master.refresh
      
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
      @wrapper.selection_changed unless e.getValueIsAdjusting
    end
  
    def install component
      component.getSelectionModel.addListSelectionListener(self)
    end
    
  end
  
  class DataAction
    include ActionHandler
    include javax.swing.event.ListDataListener
    
    def install component
      component.getModel.addListDataListener(self)
    end
    
    def contentsChanged e
    end
    
    def intervalAdded e
    end
    
    def intervalRemoved e
      @wrapper.item_removed e.getIndex0
    end
    
  end
  
  class MasterController
    
    attr_reader :registrars
    
    def initialize(window_wrapper)
      @window_wrapper = window_wrapper
      @refreshing = false
      @registrars = []
    end
    
    def << registrar
      unless registrar.added_to_master?
        @registrars << registrar
        registrar.added_to_master = true
      end
    end
    
    def refresh
      
      return if @refreshing
      
      @refreshing = true

      @registrars.each do |wrapper|
        wrapper.enable_disable
      end
      
      @refreshing = false
      
      @window_wrapper.java_component.validate
      
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
    
    def self.bind_controller view, controller = nil, method_naming_provider = nil
      prepare_mvc view, controller, method_naming_provider
    end
    
    def instantiate controller, method_naming_provider = nil
      
      window_wrapper = @def_block.call
      
      self.class.bind_controller window_wrapper, controller, method_naming_provider
      
    end

    private
    
    def self.prepare_mvc window_wrapper, controller, method_naming_provider
      
      method_naming_provider = Swiby.default_method_naming_provider unless method_naming_provider
      
      window = window_wrapper.java_component
      
      master = MasterController.new(window_wrapper)
      
      controller = window_wrapper unless controller
          
      controller.instance_variable_set :@window, window_wrapper
      
      def controller.top_window_wrapper
        @window
      end
        
      register_components window_wrapper, master, controller, method_naming_provider
      
      controller_class = controller.class
      instance_class = class << controller; self; end
      if instance_class.respond_to?(:has_bindable?) and instance_class.has_bindable?
        controller_class = instance_class
      else
        controller_class = nil unless controller_class.respond_to?(:has_bindable?) and controller_class.has_bindable?
      end
      
      if controller_class

        controller_class.bindable_fields.each do |field|
          
          setter = method_naming_provider.setter_method(field)
          
          if controller.respond_to?(setter)
            
            orig = "swiby_mvc_orig_#{setter}".to_sym
            
            code =<<CODE
            class << self
              alias :#{orig} :#{setter}
              
              def #{setter} new_value
                self.send :#{orig}, new_value
                @master.refresh
              end
              
            end
CODE
            
            controller.instance_eval code unless controller.respond_to?(orig)
            
            controller.instance_variable_set :@master, master
          
          end
        
        end
      
      end
      
      master.refresh
      
      window.visible = true
      
      window_wrapper
      
    end
    
    private
    
    def self.register_components parent, master, controller, method_naming_provider
      
      top_window_wrapper = controller.top_window_wrapper
      
      unless parent.registered?
        
        id = parent.name
        
        reg1 = parent.create_registrar(parent, master, controller, id, method_naming_provider)
        reg1.register
        
        reg2 = parent.create_registrar(parent, master, parent, id, method_naming_provider)
        reg2.register
        
        parent.registration_done reg1, reg2
        parent.registered = true
        
      end
      
      parent.each do |wrapper|
        
        id = wrapper.name
        
        if id
          
          top_window_wrapper.instance_variable_set "@#{id}".to_sym, wrapper if id.to_s =~ /^[a-zA-Z]\w*$/
          
          unless wrapper.registered?
            
            reg1 = wrapper.create_registrar(wrapper, master, controller, id, method_naming_provider)
            reg1.register
            
            reg2 = wrapper.create_registrar(wrapper, master, top_window_wrapper, id, method_naming_provider)
            reg2.register
            
            wrapper.registration_done reg1, reg2
            wrapper.registered = true
            
          end
          
        end

        if wrapper.respond_to?(:each)
          register_components wrapper, master, controller, method_naming_provider
        end
        
      end
      
      if parent.respond_to?(:each_layer)
        
        parent.each_layer do |layer|
          register_components layer, master, controller, method_naming_provider
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
  
  module MVCBase
    
    attr_accessor :registered
    
    def create_registrar wrapper, master, controller, id, method_naming_provider
      Swiby::Registrar.new(wrapper, master, controller, id, method_naming_provider)
    end
    
    def registration_done *registrars
    end
    
    def registered?
      @registered
    end
    
  end

  class SwingBase
    include MVCBase
  end
  
end