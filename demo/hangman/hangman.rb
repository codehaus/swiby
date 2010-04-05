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

class TextPlayer
  
  def propose
    
    loop do
      
      print "Letter: "
      
      input = $stdin.gets.chomp
      
      case input 
        when 'exit'
          return :stop
        when /^[a-zA-Z]$/
          return input
        else
          unknown input
      end

    end
  
  end

  def found_letters_are letters
    
    letters.each do |letter|
      print "#{letter} "
    end
    print ' '

  end

  def win letters
    found_letters_are letters
    puts
    puts "Great, you win!"
  end
  
  def lose word
    puts "You lose, the word was '#{word}'"
  end
  
  def word_was word
    puts "Word was '#{word}'"
  end
  
  def unknown command
    puts "Unknown command: #{command}"
  end

end

class Game
  
  MAX_WRONG = 8
  
  attr_reader :wrong
  
  def initialize word_distibutor
    @word_distibutor = word_distibutor
  end
  
  def start player

    new_word
    
    loop do
      
      player.found_letters_are @found_letters
      
      proposal = player.propose
      
      if proposal == :stop
        player.word_was @word
        return
      elsif  proposal == :new_word
        new_word
      else
      
        proposal = proposal.downcase
        
        if @letters.include?(proposal)
          
          begin
          
            @found_count += 1
            
            i = @letters.index(proposal)
            
            @letters[i] = ' '
            @found_letters[i] = proposal.upcase
            
          end while @letters.include?(proposal)
          
        elsif ! @word.include?(proposal)
          @wrong += 1
        end
        
        if @found_count == @word.length
          player.win @found_letters
          return
        end
        
        if @wrong >= MAX_WRONG
          player.lose @word
          return
        end
      
      end
      
    end
    
 end
  
  def new_word
    
    @wrong = 0
    
    @word = @word_distibutor.draw
    
    @letters = []
    @found_count = 0
    @found_letters = []
    
    @word.length.times do |i|
      @letters << @word[i..i]
      @found_letters << '_'
    end
    
  end
  
end

if $0 == __FILE__
  
  distributor = WordDistributor.new

  if ARGV[0]
    distributor.load ARGV[0]
  else
    distributor.load '../word_puzzle/words_en.txt'
  end

  puts "Enter a letter or 'exit'"
  
  Game.new(distributor).start TextPlayer.new
  
end