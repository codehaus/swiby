#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/swing/timer'

class ConnectionBar
  
  attr_reader :resources, :red_off, :green_off
  
  def initialize resources
    
    @resources = resources
    
    @red_off = ImageIcon.new('images/red_off.png')
    @red_on = ImageIcon.new('images/red_on.png')
    
    @green_off = ImageIcon.new('images/green_off.png')
    @green_on = ImageIcon.new('images/green_on.png')
    
    @connect_key = :connect
    
  end
  
  def resources= res
    @resources = res
    @connect.text = @resources[@connect_key] 
  end
  
  def bind connect, red, green, info
    
    @connect = connect
    @red = red
    @green = green
    @info = info
    
  end
  
  def disconnect
    
    @timer.stop if @timer
    @timer = nil
    
    @connect_key = :connect
    @connect.text = @resources[:connect]
    @info.text = ''
    
    @red.java_component.icon = @red_off
    @green.java_component.icon = @green_off
    
  end

  def connecting
    
    @connect_key = :disconnect
    @connect.text = @resources[:disconnect] 
    @info.text = @resources[:connecting] 
    
    @timer.stop if @timer
    
    @timer = every 800 do

      if @on
        @on = false
        @red.java_component.icon = @red_off
      else
        @on = true
        @red.java_component.icon = @red_on
      end
      
    end
    
  end

  def waiting_collaborator
    @info.text = @resources[:waiting]
  end
  
  def collaborating
    
    @timer.stop
    @timer = nil
    
    @info.text = @resources[:connected]
    @red.java_component.icon = @red_on
    
  end
  
  def receiving
    
    @timer.stop if @timer
    
    @info.text = @resources[:receiving]
    
    @timer = every 800 do

      if @on
        @on = false
        @green.java_component.icon = @green_off
      else
        @on = true
        @green.java_component.icon = @green_on
      end
      
    end
    
  end
  
  def stop_receiving
    @timer.stop
    @timer = nil
    @info.text = @resources[:connected]
    @green.java_component.icon = @green_off
  end
  
  def broken_connection
    
    @timer.stop if @timer
    
    @info.text = @resources[:broken_connection]
        
    @green.java_component.icon = @red_off
    
    @timer = every 800 do

      if @on
        @on = false
        @green.java_component.icon = @red_off
      else
        @on = true
        @green.java_component.icon = @red_on
      end

    end
    
  end
  
end

module Swiby

  module Builder
    
    def inject *objects
      
      target = self
      
      objects.each do |o|
        o.instance_variables.each do |var|
          target.instance_variable_set(var, o.instance_variable_get(var))
        end
      end
      
    end
    
    def inject_components
      
      target = self
      
      context.each do |field|
        
        if field.name
          name = "@#{field.name}"
          target.instance_variable_set(name, field) unless instance_variable_defined?(name)
        end
      
      end
      
    end
    
    def connection_bar resources, controller, &handler
      
      view = ConnectionBar.new(resources)
      controller.view = view
      
      panel do
        
        inject view
        
        content :layout => :absolute, :hgap => 10, :vgap => 10  do
          at [0, 0]
            button(resources[:connect], :connect) {controller.connect_disconnect}
          at [10, 0], relative_to(:connect, :right, :center)
            label @red_off, :red
          at [10, 0], relative_to(:red, :right, :center)
            label @green_off, :green
          at [10, 0], relative_to(:green, :right, :center)
            label "", :info
        end
        
        inject_components
        view.bind @connect, @red, @green, @info
        #view.bind context[:connect], context[:red], context[:green], context[:info]
        
      end
      
    end
    
  end
  
end
