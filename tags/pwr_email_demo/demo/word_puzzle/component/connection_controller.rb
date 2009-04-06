#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'thread'

class ConnectionController
  
  attr_accessor :view
  
  def initialize client, game = nil
    
    @client = client
    @game = game
    @game_board = game.board if game
    
    @queue = []
    @lock = Mutex.new
    
    @client.consumer = self
    
    @lang = :en
    @state = :disconnected
    
    start_background
    
    every 500 do
      @client.consume if connected?
    end
    
  end
  
  def change_language lang, resources
    @lang = lang
    @view.resources = resources
  end
  
  def on_connect  &handler
    @on_connect = handler
  end
  
  def on_disconnect &handler
    @on_disconnect = handler
  end
  
  def connected?
    @state == :connected or @state == :receiving or @state == :broken
  end
  
  def receiving?
    @state == :receiving
  end
  
  def connect_disconnect
    
    if connected? or @state == :connecting
      disconnect
    else
      connect
    end
    
  end
  
  def start_receiving
    
    return unless @state == :connected
    
    @state = :receiving    
    @view.receiving
    
  end
  
  def stop_receiving
    
    return unless @state == :receiving
    
    @state = :connected
    @view.stop_receiving
    
  end
  
  def connect
    
    @state = :connecting    
    @view.connecting
    
    @lock.synchronize do
      
      @queue << proc { 
        
        @client.register
        
        @view.waiting_collaborator if @state == :connecting
        
        grid = nil
        
        loop do
          
          break if @state == :disconnected
          
          grid = @client.collaborate(@lang)
        
          break if grid != 'none'
          
        end

        grid = @client.build_grid(grid)
        @game.change_grid grid
        @game.restart grid
        
        if @state == :connecting
          @state = :connected
          @view.collaborating
        else
          @view.disconnect
        end
        
      }
      
    end
    
    @on_connect.call if @on_connect
    
  end
  
  def disconnect
    
    stop_receiving
    
    @state = :disconnected
    @view.disconnect
    
    @lock.synchronize do
      @queue << proc { @client.unregister }
    end
    
    @on_disconnect.call if @on_disconnect
    
  end
  
  def start_background
    
    Thread.new do
      
      loop do
        
        sleep 0.2
        
        unless @queue.empty?
        
          command = nil

          @lock.synchronize do
            command = @queue.shift
          end
        
          command.call if command
          
        end
        
      end
      
    end
    
  end
  
  def mouse_down r, c
    
    @row = r
    @col = c
    
    start_receiving unless receiving?
    
  end
  
  def mouse_up r, c
    @game_board.backdoor_position(nil, nil) if @game_board
    stop_receiving
  end
  
  def mouse_move r, c
    @game_board.backdoor_position([@row, @col], [r, c]) if @game_board
  end
  
  def word_found word
    stop_receiving
    @game_board.backdoor_word word
  end
      
  def broken
    
    stop_receiving
    
    @state = :broken
    @view.broken_connection
    
  end
  
end
