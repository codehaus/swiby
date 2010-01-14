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

require 'swiby/component/frame'
require 'swiby/component/button'
require 'swiby/component/radio_button'

class Word
  
  def <=> other
     @text <=> other.text
  end
   
  def humanize
    @text
  end
  
end

class PuzzleGame
  
  attr_reader :grid, :words, :hint_enabled
  
  def initialize grid_factory
    @language = :en
    @hint_enabled = true
    @grid_factory = grid_factory
  end
  
  def board
    @frame[0][:board]
  end
  
  def create

    @grid = @grid_factory.create
    
    change_grid @grid
        
  end
  
  def button name
    @frame[0][1][name]
  end
  
  def show show_visible = true
    
    if ARGV[0]
      styles = load_styles(ARGV[0])
    else
      styles = load_styles('styles/kite_styles.rb')
    end

    game = self

    @frame = frame {

      use_styles styles
      
      autosize

      title "Word Search Puzzle"

      content {
    
        panel(:layout => :border) {
          
          puzzle_board(game.grid, :board) { |word|
            game.found word
          }
          
          south
            panel {
              content(:layout => :absolute, :hgap => 10, :vgap => 10) {
                at [0, 0]
                  button("Resolve", :resolve) {game.resolve}
                  
                at [60, 40], relative_to(:resolve, :align, :below)
                  button("New", :new) { game.new_puzzle }
                  
                at [50, 20], relative_to(:new, :right, :below)
                  button("Again", :restart)  { game.restart }
                
                at [80, 0], relative_to(:restart, :right, :align)
                  button("Exit!", :exit) { exit }
                  
                at [100, 0], relative_to(:resolve, :right, :below)
                  radio_group(:horizontal, nil, ["Easy", "Medium", "Advanced"], "Easy", :name => :level) { |choice|
                    game.level = choice
                  }
                  
                at [0, 110], relative_to(:resolve, :align, :below)
                  hover_button('french', :name => :language)  {game.change_language}
                  
              }
              
            }
            
        }
        
        east
          list_view(:list_view, Array.new(game.words)) { |x|
            context[0][:board].hint_for x if game.hint_enabled
          }
          
      }
      
      swing { |f|
        f.resizable = false
      }

      visible true if show_visible
      
    }
    
  end
  
  def new_puzzle
    
    create
    restart @grid
    
    auto_size
    
  end
  
  def change_grid  grid
    
    @words = []

    grid.each_word do |word|
      @words << word
    end

    @words.sort!
    
  end
  
  def restart grid = nil
    
    @frame[0][:board].restart grid
    @frame[:list_view].content = Array.new(@words)
    
    auto_size
    
  end
  
  def resolve
    @frame[0][:board].show_words
  end
  
  def found word
    @frame[:list_view].remove(word)
  end
  
  def level= level
    
      case level
        when "Easy"
          @hint_enabled = true
          @frame[:list_view].java_component.visible = true
        when "Medium"
          @hint_enabled = false
          @frame[:list_view].java_component.visible = true
        when "Advanced"
          @hint_enabled = false
          @frame[:list_view].java_component.visible = false
        end
        
        auto_size
          
  end

  def auto_size

    if @frame[:list_view].item_count == 0
      @frame[:list_view].java_component.set_preferred_size(@list_preferred_size) if @list_preferred_size
    else
      @list_preferred_size = @frame[:list_view].java_component(true).get_preferred_size
      @frame[:list_view].java_component.set_preferred_size(@list_preferred_size)
    end

    @frame.java_component.pack
    
  end
  
  def change_language
    
    p = @frame[0][1]
    
    if @language == :en
      
      @frame.title = "Recherche de mots"
      
      p[:resolve].text = "Solution"
      p[:new].text = "Autre"
      p[:exit].text = "Quitter!"
      p[:restart].text = "Encore"
      p[:language].text = "anglais"

      p = p[:level]
      
      p[0].text = "Facile"
      p[1].text = "Moyen"
      p[2].text = "Difficile"

      @language = :fr
      
    else
      
      @frame.title = "Word Search Puzzle"
      
      p[:resolve].text = "Resolve"
      p[:new].text = "New"
      p[:exit].text = "Exit!"
      p[:restart].text = "Again"
      p[:language].text = "french"

      p = p[:level]
      
      p[0].text = "Easy"
      p[1].text = "Medium"
      p[2].text = "Advanced"

      @language = :en
      
    end
      
    @grid = @grid_factory.change_language @language
      
    new_puzzle
    
  end

end

if $0 == __FILE__
  
  require 'optparse'
  
  options = {:remote => false, :host => 'localhost', :port => 3000}
  
  parser = OptionParser.new do |opts|
    
    opts.banner = "Usage: #{$0} [options]"
    
    opts.on("-r", "--remote", "Use a remote server") do
      options[:remote] = true
    end
    
    opts.on("-h", "--host name", "HTTP host name/ip of the server") do |h|
      options[:host] = h
    end
    
    opts.on("-p", "--port num", "HTTP port of the server") do |p|
      options[:port] = p.to_i
    end
    
  end
  
  parser.parse!
  
  if options[:remote]
    
    require 'puzzle/collab_factory'
    
    game = PuzzleGame.new(CollabFactory.new(options[:host], options[:port]))
    
  else
    
    require 'puzzle/grid_factory'

    game = PuzzleGame.new(GridFactory.new)
    
  end

  game.create
  game.show

end
