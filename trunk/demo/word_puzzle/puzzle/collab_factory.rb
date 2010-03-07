#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'component/connection_bar'
require 'component/connection_controller'

require 'puzzle_client'
require 'puzzle_game'

class CollabFactory
  
  attr_reader :client
  
  def initialize host, port
      @lang = :en
      @client = PuzzleClient.new(30, "http://#{host}:#{port}")
  end
      
  def create cols = 10, rows = 10
    @client.new_grid @lang
  end
  
  def change_language lang
    @lang = lang
  end
  
end

class PuzzleGame
  
  alias :normal_show :show
  alias :normal_change_language :change_language
  
  FRENCH_RES = {
    :connect => 'Collaborer'.to_utf8, 
    :disconnect => 'Déconnecter'.to_utf8, 
    :connecting => 'connexion en cours...'.to_utf8,
    :waiting => 'attente...'.to_utf8, 
    :connected => 'connecté'.to_utf8, 
    :receiving => 'en cours de réception...'.to_utf8,
    :broken_connection => 'collaboration arrêtée!'.to_utf8
  }
  ENGLISH_RES = {
    :connect => 'Collaborate', 
    :disconnect => 'Disconnect', 
    :connecting => 'connecting...',
    :waiting => 'waiting...', 
    :connected => 'connected', 
    :receiving => 'receiving...',
    :broken_connection => 'collaboration stopped!'
  }
    
  def show
    
    normal_show false
    
    client = @grid_factory.client
    
    @controller = ConnectionController.new(client, self)
    controller = @controller

    resources = ENGLISH_RES
    
    @frame.instance_eval do
      
      content do
        south
          connection_bar resources, controller
          
      end
        
    end
      
    @frame.apply_styles
    
    auto_size
    
    @frame.visible true
    
    register_listeners client
    
    controller.on_connect do
      button(:resolve).enabled = false
      button(:new).enabled = false
      button(:restart).enabled = false
    end
    
    controller.on_disconnect do
      button(:resolve).enabled = true
      button(:new).enabled = true
      button(:restart).enabled = true
    end
    
    @frame.hide_on_close
    @frame.on_close do
      client.unregister
      exit
    end
    
    button(:exit).action do
      client.unregister
    end
    
  end
  
  def change_language
    
    normal_change_language
    
    if @language == :en
      @controller.change_language :en, ENGLISH_RES
    else
      @controller.change_language :fr, FRENCH_RES
    end
      
  end
  
  def register_listeners client
    
    controller = @controller
    
    board.on_user_activity do
      
      @client = client
      @controller = controller
      
      def start_word row, col
        @client.fire_mouse_down row, col if @controller.connected?
      end
      
      def continue_word row, col
        @client.fire_mouse_move row, col if @controller.connected?
      end
      
      def end_word row, col
        @client.fire_mouse_up row, col if @controller.connected?
      end
      
      def found_word word
        @client.fire_found word if @controller.connected?
      end
      
    end
    
  end
  
end
