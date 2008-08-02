#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby'
require 'swiby/form'
require 'swiby/swing/timer'

require 'component/connection_bar'
require 'component/connection_controller'

class ClientMock
  
  def initialize
    @events = []
    @collaborators = 0
  end
  
  def consumer= consumer
    @consumer = consumer
  end
  
  def register
    sleep 0.8
    'ok'
  end

  def unregister
    @break_button.enabled = false
    @receive_button.enabled = false
    @receive_button.text = 'Receive'
  end
      
  def collaborate
    return 'none' if @collaborators == 0
    @collaborators -= 1
    @break_button.enabled = true
    @receive_button.enabled = true
    'ok'
  end
  
  def consume &handler
    
    return if @events.empty?
    
    if handler.nil?
      handler = @consumer
    else
      handler.instance_eval(&handler)
    end
        
    ev = @events.shift
    
    if ev == :md
      handler.mouse_down 1, 3
    elsif ev == :broken
      handler.broken
    else
      handler.word_found "hello"
    end
    
  end
  
  def receive_button= receive_button
    @receive_button = receive_button
    @receive_button.enabled = false
  end
  
  def break_button= break_button
    @break_button = break_button
    @break_button.enabled = false
  end
  
  def receive_toggle
    
    if @receive_button.text == 'Receive'
      start_receiving
      @receive_button.text = 'Stop receive'
    else
      stop_receiving
      @receive_button.text = 'Receive'
    end
    
  end
  
  def break_connection
    @events.clear
    @events << :broken
    @receive_button.enabled = false
    @break_button.enabled = false
  end
  
  def add_collaborator
    @collaborators += 1
  end

  def start_receiving
    @events << :md
  end

  def stop_receiving
    @events << :wf
  end
  
end

client = ClientMock.new
controller = ConnectionController.new(client)

resources = {
  :connect => 'Connect', 
  :disconnect => 'Disconnect', 
  :connecting => 'connecting...',
  :waiting => 'waiting...', 
  :connected => 'connected', 
  :receiving => 'receiving...',
  :broken_connection => 'broken connection!'
}

frame do
  
  title "Test Connection Bar"

  width 280
  height 180
  
  content do
    
    center
      panel do
        
        content :layout => :stacked, :vgap => 5, :sizing => :maximum do
          
          button "Add Collaborator" do
            client.add_collaborator
          end
          
          button 'Receive', :receive_button do
            client.receive_toggle
          end
          
          button 'Break Connection', :break_button do
            client.break_connection
          end
          
          client.receive_button = context[:receive_button]
          client.break_button = context[:break_button]
          
        end
      
      end
      
    south
      connection_bar resources, controller
    
  end
      
  visible true
  
end
