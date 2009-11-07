#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'hidden_number'

describe "Game" do

  def stopping_player
    
    player = mock "Player"
    
    player.should_receive(:propose).and_return(:stop)
    player.should_receive(:bye).with(0)
    
    player
    
  end

  def winning_player
    
    player = mock "Player"
    
    player.should_receive(:propose).and_return(11)
    player.should_receive(:win).with(1)
    
    player
        
  end
  
  def winning_after_3_guesses_player
    
    player = mock "Player"
    
    player.should_receive(:propose).and_return(1, 1, 11)
    player.should_receive(:higher).exactly(2).times
    player.should_receive(:win).with(3)
    
    player
        
  end
  
  def one_guess_player guess
    
    player = mock "Player"
    
    player.should_receive(:propose).and_return(guess, :stop)
    
    if guess > 11
      player.should_receive(:lower)
    else
      player.should_receive(:higher)
    end
    
    player.should_receive(:bye).with(1)
    
    player
    
  end
  
  def losing_player
    
    player = mock "Player"
    
    player.should_receive(:propose).and_return(1,1,1,1,1,1,1,1,1,1)
    player.should_receive(:higher).exactly(9).times
    player.should_receive(:lose).with(11, Game::MAX_GUESSES)
    
    player
    
  end

  def restart_and_win_player
    
    player = mock "Player"
    
    player.should_receive(:propose).and_return(1, :restart, 11)
    player.should_receive(:higher)
    player.should_receive(:win).with(1)
    
    player
        
  end
  
  before :each do  
    @game = Game.new

    def @game.forced_hidden= number
      @forced_hidden = number 
    end
    
    def @game.draw_a_number
    
      super
        
      @hidden_number = @forced_hidden if @forced_hidden
        
    end

  end
  
  it "should allow user to stop the game" do
    @game.start stopping_player
  end

  it "should draw a number with the given number of digits" do
    
    @game.number_of_digits = 1
    
    @game.start stopping_player
    
    @game.hidden_number.should >= 0
    @game.hidden_number.should <= 9
    
  end
  
  it "should draw a number within the given range" do
    
    @game.digits_range = (78..80)
    
    @game.start stopping_player
    
    @game.hidden_number.should >= 78
    @game.hidden_number.should <= 80
    
  end

  it "should end if the proposal matches the hidden number" do
    
    @game.forced_hidden = 11
    
    @game.start winning_player
    
  end

  it "should end if the proposal matches the hidden number and give the right amount of guesses" do
    
    @game.forced_hidden = 11
    
    @game.start winning_after_3_guesses_player
    
  end
  
  it "should send lower if proposal is too high" do
    
    @game.forced_hidden = 11
    
    @game.start one_guess_player(20)
    
  end
  
  it "should send higher if proposal is too low" do
    
    @game.forced_hidden = 11
    
    @game.start one_guess_player(5)
    
  end

  it "should end if the player consumes maximum guesses" do
    
    @game.forced_hidden = 11
    
    @game.start losing_player
    
  end

  it "should restart the game on player's demand" do
    
    @game.forced_hidden = 11
    
    @game.start restart_and_win_player
    
  end

end