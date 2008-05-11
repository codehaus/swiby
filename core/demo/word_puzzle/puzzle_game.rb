#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

$SWIBY_EXT_PATHS = [File.dirname(__FILE__) ]

require 'swiby'

require 'puzzle/distributor'
require 'puzzle/puzzle_builder'

class Word
  
  def <=> other
     @text <=> other.text
  end
   
  def humanize
    @text
  end
  
end

Defaults.auto_sizing_frame = true

class PuzzleGame
  
  attr_reader :grid, :words, :hint_enabled
  
  def initialize
    @language = :en
    @hint_enabled = true
    @dist = WordDistributor.new
    @dist.load 'words_en.txt'
  end
  
  def create

    #builder = PuzzleBuilder.new(15, 15)
    #builder = PuzzleBuilder.new(5, 5)
    builder = PuzzleBuilder.new(10, 10)

    while not @dist.empty?

      word = @dist.draw
      
      if not builder.add(word)
        @dist.filter_out(word.length)
      end
      
    end

    @grid = builder.close
    
    @words = []

    @grid.each_word do |word|
      @words << word
    end

    @words.sort!
        
  end
  
  def show
    
    game = self

    @frame = frame do

      use_styles load_styles('styles.rb')
      
      title "Word Search Puzzle"

      content do
    
        panel :layout => :border do
          
          puzzle_board game.grid, :board do |word|
            game.found word
          end
          
          south
            panel do
              content :layout => :absolute, :hgap => 10, :vgap => 10  do
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
                  label('french', :name => :language) {
                    
                    @game = game
                    
                    def on_click ev
                      @game.change_language
                    end
                    
                    def on_mouse_over ev
                      @normal_color = context[:language].java_component.foreground
                      context[:language].java_component.foreground = AWT::Color::RED
                    end
                    
                    def on_mouse_out ev
                      context[:language].java_component.foreground = @normal_color
                    end
                    
                  }
                  
              end
              
            end
            
        end
        
        east
          list_view :list_view, Array.new(game.words) do |x|
            context[0][:board].hint_for x if game.hint_enabled
          end
          
      end
      
      swing do |f|
        f.resizable = false
      end

      visible true
      
    end
    
  end
  
  def new_puzzle
    
    @dist.reset
    
    create
    restart @grid
    
    auto_size
    
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
      @dist.load 'words_fr.txt'
      
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
      @dist.load 'words_en.txt'
      
    end
      
    new_puzzle
    
  end

end

game = PuzzleGame.new

game.create
game.show