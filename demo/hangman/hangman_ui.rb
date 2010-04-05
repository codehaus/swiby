#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

$LOAD_PATH << File.expand_path('../word_puzzle', File.dirname(__FILE__))

require 'puzzle/distributor'

require 'swiby/mvc/label'
require 'swiby/mvc/panel'
require 'swiby/mvc/button'

require 'swiby/layout/absolute'

require 'component/hangman_board'

require 'hangman'

CONTEXT.missing_translation_enabled = false

title "Hangman Game"

LETTERS_TOP = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"]
LETTERS_BOTTOM = ["O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

panel = content {

  use_styles 'hangman_styles.rb'

  panel(:layout => :absolute) {
  
    at [0, 0]
      hangman_board :board, 320, 320
      
    at [10, 0], relative_to(:board, :right, :align_bottom_edge)
      label ' ', :name => :found
          
    at [0, 20], relative_to(:board, :align, :below)
      panel(:name => :letters_part_1) {
        LETTERS_TOP.each { |letter|
          button letter, letter.to_sym, :style_class => :keys
        }
      }
    at [40, 10], relative_to(:letters_part_1, :align, :below)
      panel(:name => :keyboard) {
        LETTERS_BOTTOM.each { |letter|
          button letter, letter.to_sym, :style_class => :keys
        }
      }
          
    at [20, 30], relative_to(:board, :right, :align)
      button 'new!', :name => :new_word

    at [20, 30], relative_to(:new_word, :right, :below)
      button 'resolve', :name => :resolve
          
    at [20, 30], relative_to(:resolve, :right, :below)
      button 'exit', :name => :exit_application
          
    at [20, 120], relative_to(:new_word, :align, :below)
      label '', :name => :number_of_letters
      
    at [-40, 10], relative_to(:keyboard, :align, :below)
      hover_button('french', :name => :language)
  }

}
    
$context.start
        
class PlayerController
        
  bindable :found
  attr_accessor :found
  attr_accessor :language_command_text
    
  letters = LETTERS_TOP + LETTERS_BOTTOM
    
  letters.each do |letter|
    
    define_method(letter.to_sym) {
      @entry = @last_letter = letter if @playing
    }
    
    define_method("may_#{letter}?".to_sym) {
      @playing
    }

  end
  
  def initialize distributor

    @language_command_text = 'french'
    
    @game = Game.new(distributor)
    
    @found = ''
    
    start
    
  end
    
  def exit_application
    exit
  end
  
  def start
    
    @playing = true
    
    Thread.new do
      
      begin
        @game.start self
      rescue => e
        puts "Error in thread => #{e}"
        trace = e.backtrace
        puts trace.join("\n")
      end

      @playing = false
    
    end
    
  end

  def language
    
    if Swiby::CONTEXT.language == :en
      @language_command_text = 'english'
      Swiby::CONTEXT.language = :fr
    else
      @language_command_text = 'french'
      Swiby::CONTEXT.language = :en
    end
    
  end
  
  def new_word
    
    @last_letter = nil
    
    (LETTERS_TOP + LETTERS_BOTTOM).each do |letter|
      @window.find(letter.to_sym).style_class = :keys
    end
    
    @window.apply_styles
    
    if @playing
      @entry = :new_word
    else
      start
    end
    
  end
  
  def number_of_letters
    nb_letters = @found.length / 2 + 1
    :nb_letters.apply_substitution binding
  end
  
  def resolve
    @entry = :stop
    @playing = false
  end
  
  def may_resolve?
    @playing
  end
  
  def propose
    
    @entry = nil
    
    sleep 0.1 until @entry
    
    @entry
    
  end
    
  def win letters
    @playing = false
    found_letters_are letters
  end
    
  def found_letters_are letters
    
    if @window
      
      @window.find(:board).errors_count = @game.wrong
    
      letters.each do |letter|
        @last_letter = nil if @last_letter == letter
        @window.find(letter.to_sym).style_class = :valid_letter unless letter == '_'
      end
      
      if @last_letter and !letters.include?(@last_letter.upcase!)
        @window.find(@last_letter.to_sym).style_class = :invalid_letter
      end
      
      @last_letter = nil
    
      @window.apply_styles
      
    end
    
    self.found = letters.join(' ')
    
  end
  
  def lose word
    
    @playing = false
    
    @window.find(:board).errors_count = @game.wrong
    
    word_was word
    
  end
  
  def word_was word
    
    letters = ''
    
    word.length.times do |i|
      letters += "#{word[i..i]} "
    end
    
    self.found = letters.upcase
    
  end
  
end

distributor = WordDistributor.new

if ARGV[0]
  distributor.load ARGV[0]
else
  distributor.load '../word_puzzle/words_en.txt'
end

ViewDefinition.bind_controller panel, PlayerController.new(distributor)

$context.reload_hook do
  
  s = load_styles("hangman_styles.rb")
  
  panel.apply_styles s
  
end
