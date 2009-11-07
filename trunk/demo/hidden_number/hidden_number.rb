#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class TextPlayer
  
  def propose
    
    loop do
      
      puts "Enter a guess or 'exit'"
      print "Your guess: "
      
      input = gets.chomp
      
      case input 
        when /^[\d]*$/
          return input.to_i
        when 'exit'
          return :stop
        else
          unknown input
      end

    end
  
  end
  
  def higher number_of_guesses
    puts "Higher"
  end
  def lower number_of_guesses
    puts "Lower"
  end
  def bye number_of_guesses
    puts "Bye"
  end
  def win number_of_guesses
    puts "You win"
  end
  def lose hidden_number, number_of_guesses
    puts "You lose, the hidden number was: #{hidden_number}"
  end

  def unknown command
    puts "Unknown command: #{command}"
  end
  
end

class Game

  attr_reader :number_of_guesses
  attr_reader :hidden_number
  
  attr_accessor :number_of_digits, :digits_range

  MAX_GUESSES = 10
  
  def initialize
    @number_of_guesses = 0
    @number_of_digits = 2
  end
  
  def start player
  
    draw_a_number

    loop do
      
      proposal = player.propose
      
      case proposal
        when :stop
          player.bye @number_of_guesses
          return

        when Integer
        
          @number_of_guesses += 1
          
          if proposal == @hidden_number
            
            player.win @number_of_guesses
            
            return
            
          else
            
            if @number_of_guesses >= MAX_GUESSES
              
              player.lose @hidden_number, @number_of_guesses
              
              return
              
            else  
              player.higher @number_of_guesses if proposal < @hidden_number
              player.lower @number_of_guesses if proposal > @hidden_number 
            end
          
          end

        when :restart
          draw_a_number
      
      end
        
    end
    
  end
  
  def draw_a_number
    
    if @digits_range
      @hidden_number = rand(@digits_range.last - @digits_range.first + 1) + @digits_range.first
    else
      @hidden_number = rand(10 ** @number_of_digits)
    end
  
    @number_of_guesses = 0
    
  end
  
end

if $0 == __FILE__
  Game.new.start TextPlayer.new
end