#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/swing/timer'

require 'swiby/mvc/frame'
require 'swiby/mvc/label'
require 'swiby/mvc/button'

class MyController
  
  bindable :message
  attr_accessor :message
  
  def results
    @message = '<no message>' unless @message
    @message
  end
  
  def click_me
    
    self.message = "You clicked the 'Click me!' button (clear automatically)"
    
    after(2000) do
      self.message = "cleared..."
    end
    
  end
    
end

class MVCBindableTest < ManualTest
  
  manual "Bindable with a controller class" do

    controller = MyController.new
    
    ViewDefinition.bind_controller bindable_create_view, controller
    
  end
  
  manual "Bindable with a controller's instance-class" do

    controller = Object.new
    
    bindable_add_handlers controller
        
    ViewDefinition.bind_controller bindable_create_view, controller
    
  end

  manual "Bindable with view's instance-class" do

    view = bindable_create_view
    
    bindable_add_handlers view

    ViewDefinition.bind_controller view
    
  end
  
  manual 'Bindable with view only' do
  
    view = form {
      
      bindable :message
      attr_accessor :message
      
      title 'Bindable'
      
      width 400
      height 200
      
      label '', :name => :results
      button "Click me!", :name => :click_me
      
      visible true
      
      def results
        @message = '<no message>' unless @message
        @message
      end
      
      def click_me
        
        self.message = "You clicked the 'Click me!' button (clear automatically)"
        
        after(2000) do
          self.message = "cleared..."
        end
        
      end
      
    }
    
    ViewDefinition.bind_controller view
    
  end
    
end

def bindable_create_view
  
  form {
    
    title 'Bindable'
    
    width 400
    height 200
    
    label '', :name => :results
    button "Click me!", :name => :click_me
    
    visible true    
    
  }
  
end

def bindable_add_handlers o
  
  class << o
    
    bindable :message
    attr_accessor :message
    
    def results
      @message = '<no message>' unless @message
      @message
    end
    
    def click_me
      
      self.message = "You clicked the 'Click me!' button (clear automatically)"
      
      after(2000) do
        self.message = "cleared..."
      end
      
    end
    
  end
    
end
