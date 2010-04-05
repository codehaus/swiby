#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby'

require 'component/list_view'
require 'component/puzzle_board'

require 'swiby/layout/stacked'
require 'swiby/layout/absolute'

require 'swiby/mvc/list'
require 'swiby/mvc/frame'
require 'swiby/mvc/button'
require 'swiby/mvc/radio_button'

Swiby::CONTEXT.missing_translation_enabled = false

class Word
  
  def <=> other
     @text <=> other.text
  end
   
  def humanize
    @text
  end
  
end

class PuzzleGame
  
  attr_reader :grid, :words
  
  def initialize grid_factory
    @grid_factory = grid_factory
  end
  
  def new_puzzle
    
    @grid = @grid_factory.create
    
    @words = []

    @grid.each_word do |word|
      @words << word
    end

    @words.sort!
    
  end

  def change_language
    
    @grid = @grid_factory.change_language Swiby::CONTEXT.language
    
    new_puzzle
    
  end

end

class PuzzleGameController
  
  attr_accessor :switch_language_command_text
  
  def initialize game
    @game = game
    @switch_language_command_text = 'french'
  end
  
  def new_game
    @game.new_puzzle
    @window.restart true
  end
  
  def switch_language
    
    if Swiby::CONTEXT.language == :en
      @switch_language_command_text = 'english'
      Swiby::CONTEXT.language = :fr
    else
      @switch_language_command_text = 'french'
      Swiby::CONTEXT.language = :en
    end
    
    @game.change_language
    
    @window.restart true
    
  end
  
  def found word
    @window.remove_word(word)
  end
  
end

if $0 == __FILE__
  
  require 'swiby/util/arguments_parser'
  
  parser = create_parser_for('WordPuzzleGame', '1.0') {
    
    accept optional, :remote, '-r', '-remote', :doc => 'Use a remote server'
    accept optional, :host, '-h', '-host-name', :doc => 'HTTP host name/ip of the server'
    accept optional, :port, '-p', '-port-num', :doc => 'HTTP port of the server'
    accept_remaining optional, :styles, "Style definition file."
    
    validator do |options|
      
      if options.port
        options.port = options.port.to_i
      else
        options.port = 3000
      end
    
      options.host = 'localhost' unless options.host
      
    end
      
    exception_on_error
    
  }

  options = parser.parse(ARGV)
  
  if options.remote
    
    require 'puzzle/collab_factory'
    
    game = PuzzleGame.new(CollabFactory.new(options.host, options.port))
    
  else
    
    require 'puzzle/grid_factory'

    game = PuzzleGame.new(GridFactory.new)
    
  end

  game.new_puzzle

  if options.styles
    styles = load_styles(options.styles[0])
  else
    styles = load_styles('styles/kite_styles.rb')
  end
  
  view = frame {

    @game = game
    @hint_enabled = true
    
    use_styles styles
    
    autosize
        
    swing { |f|
      f.resizable = false
    }

    title "Word Search Puzzle"

    panel(:layout => :border) {
      
      puzzle_board game.grid, :board
      
      south
        panel(:layout => :absolute) {
          
          at [0, 0]
            button "Resolve", :resolve
            
          at [60, 40], relative_to(:resolve, :align, :below)
            button "New", :new_game
            
          at [50, 20], relative_to(:new_game, :right, :below)
            button "Again", :restart
          
          at [60, 0], relative_to(:restart, :right, :align)
            button "Exit!", :exit
            
          at [100, 0], relative_to(:resolve, :right, :below)
            radio_group(:horizontal, nil, ["Easy", "Medium", "Advanced"], "Easy", :name => :level)
            
          at [0, 110], relative_to(:resolve, :align, :below)
            hover_button 'french', :name => :switch_language
              
        }
          
    }
      
    east
      list_view(:words, Array.new(game.words))

    visible true
  
    def resolve
      @board.show_words
    end
    
    def remove_word word
      @words.remove(word)
    end
    
    def restart new_grid = false
      
      if new_grid
        @board.restart @game.grid
      else
        @board.restart
      end
    
      @words.content = Array.new(@game.words)
      
      auto_size
      
    end
    
    def level= level
      
      case level
      when "Easy"
        @hint_enabled = true
        @words.java_component.visible = true
      when "Medium"
        @hint_enabled = false
        @words.java_component.visible = true
      when "Advanced"
        @hint_enabled = false
        @words.java_component.visible = false
      end
      
      auto_size
            
    end
        
    def words= word
      @board.hint_for word if word and @hint_enabled
    end
    
    def auto_size
      
      if @words.item_count == 0
        @words.java_component.preferred_size = @list_preferred_size if @list_preferred_size
      else
        @list_preferred_size = @words.java_component(true).preferred_size
        @words.java_component.preferred_size = @list_preferred_size
      end
      
      java_component.pack
      
    end
    
  }
    
  ViewDefinition.bind_controller view, PuzzleGameController.new(game)
  
end
