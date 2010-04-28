#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout/grid'
require 'swiby/layout/stacked'

require 'swiby/mvc/text'
require 'swiby/mvc/combo'
require 'swiby/mvc/button'
require 'swiby/mvc/label'
require 'swiby/mvc/progress_bar'

require 'hidden_number'

title "Hidden Number Game"

width 640
height 470

panel = content(:layout => :flow) {

  use_styles 'hidden_styles.rb'
  
  form {
  
    section "Game"
      input "Your Guess", "", :name => :guess

      num_pad = [7, 8, 9] +
                [4, 5, 6] +
                [1, 2, 3] +
                [0      ]
                        
      grid(:columns => 3) {
        num_pad.each { |key|
          button key.to_s, :name => key.to_s.to_sym, :style_class => :numeric_pad
        }

        column :span => 2
          button 'Clear', :name => :clear, :style_class => :numeric_pad
      }
      
      command "Propose", :name => :submit
      
    section "Control"
      combo "Range", [], :name =>:number_of_digits
      button 'Start', :name => :start
      button "Restart", :name => :restart
      button "Exit", :name => :exit_application

    next_row
      label '', :name => :message
      progress :horizontal, Game::MAX_GUESSES, :tries_left, :value => Game::MAX_GUESSES
      
  }

}

$context.start

class PlayerController
  
  attr_accessor :message
  bindable :message

  def initialize
    @message = 'Game not started'
    @game = Game.new
    @started = false
  end
  
  def exit_application
    exit
  end
  
  def start
    
    @message = ' '

    @entry = ''
    @started = true
    @tries_left = Game::MAX_GUESSES

    Thread.new do
      
      begin
        @game.start self
      rescue => e
        puts "Error in thread => #{e}"
        trace = e.backtrace
        puts trace.join("\n")
      end

    end
    
  end
  
  def may_start?
    not @started
  end

  def propose
    
    @command = nil
    
    sleep 0.1 until @command
    
    @command
    
  end

  def higher number_of_guesses
    @tries_left = Game::MAX_GUESSES - number_of_guesses
    self.message = "<html>Guess #{number_of_guesses} with value #{@guess} was too <b>low</b>"
  end
  def lower number_of_guesses
    @tries_left = Game::MAX_GUESSES - number_of_guesses
    self.message = "<html>Guess #{number_of_guesses} with value #{@guess} was too <b>high</b>"
  end
  def win number_of_guesses
    @started = false
    self.message = "<html>You win!"
  end
  def lose hidden_number, number_of_guesses
    @started = false
    @tries_left = 0
    self.message = "<html>You lose, the hidden number was: #{hidden_number}"
  end

  def guess
    @entry
  end
  
  def guess= value
    @entry = value
  end
  
  def tries_left
    @tries_left
  end
  
  def formated_tries_left
    
    if not @started
      ''
    elsif @tries_left == 1
      'last try'
    else
     "#{@tries_left} tries left"
    end

  end
    
  def clear
    @entry = ''
  end
  
  def may_clear?
    @started
  end
        
  def submit
    @command = @entry.to_i
    @guess = @entry
    @entry = ''
  end
  
  def may_submit?
    not may_start?
  end
  
  def restart
    @message = ' '
    @command = :restart
    @tries_left = Game::MAX_GUESSES
  end
  
  def may_restart?
    not may_start?
  end
  
  def list_of_number_of_digits
    
    @list_provided = true
    
    [(1..20), (1..30), (1..50), (20..80), (1..90), (1..100), (1..500)]
    
  end
  
  def list_of_number_of_digits_changed?
    not @list_provided
  end
  
  def number_of_digits
    @game.number_of_digits
  end
  
  def number_of_digits= x
    @game.digits_range = x
  end
  
  10.times do |i|
    
    name = i.to_s
    
    define_method(name.to_sym) {
      @entry += name
    }
    
    define_method("may_#{name}?".to_sym) {
      @started
    }
    
  end

end

ViewDefinition.bind_controller panel, PlayerController.new

$context.reload_hook do
  
  s = load_styles("hidden_styles.rb")
  $context.apply_styles s
  
end