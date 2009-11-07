#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'puzzle_server'
require 'puzzle_client'

describe PuzzleServer, :shared => true do
  
  before :each  do
    @client = PuzzleClient.new
  end
  
  after :each  do
    @client.unregister
    @other.unregister if @other
  end
  
  it "should return a new puzzle grid" do
    response = @client.post('/puzzle/new')
    response.should be_a_grid_definition
  end
  
  it "should accept language parameter" do
    response = @client.post('/puzzle/new', 'lang' => :en)
    response.should be_a_grid_definition
  end
  
  it "should return 'unsupported' for unsupported languages" do
    response = @client.post('/puzzle/new', 'lang' => :marchy)
    response.should == 'unsupported'
  end

  it "should return 'welcome' for new registering clients" do
    response = @client.get('/puzzle/register')
    response.should == 'welcome'
  end
  
  it "should return 'love' if a client registers again" do
    response = @client.get('/puzzle/register')
    response = @client.get('/puzzle/register')
    response.should == 'love'
  end
  
  it "should return 'bye' when a client unregisters" do
    response = @client.get('/puzzle/register')
    response = @client.get('/puzzle/unregister')
    response.should == 'bye'
  end
  
  it "should return 'error' when an unregistered client tries unregistering" do
    response = @client.get('/puzzle/unregister')
    response.should == 'error'
  end
  
  it "should unregister clients after a timeout duration" do
    
    response = @client.get('/puzzle/register')
    
    sleep 3
    
    response = @client.get('/puzzle/register')
    
    show_help_tip(response)
    
    response.should == 'welcome'
    
  end
  
  it "should start collaboration as soon a player is available" do
    
    response = @client.get('/puzzle/register')
    response = @client.get('/puzzle/collaborate')
    response.should == 'none'
    
    @other = PuzzleClient.new
    @other.get('/puzzle/register')
    
    response = @client.post('/puzzle/collaborate', 'lang' => :en)
    
    response = @other.post('/puzzle/collaborate', 'lang' => :en)
    response.should_not == 'none'
    
    response = @client.post('/puzzle/collaborate', 'lang' => :en)
    response.should_not == 'none'
    
  end
  
  it "should return the same new grid to both partners, when starting collaboration" do

    @other = PuzzleClient.new
    @other.get('/puzzle/register')
    
    @client.get('/puzzle/register')
    @client.post('/puzzle/collaborate', 'lang' => :en)
    
    grid1 = @other.post('/puzzle/collaborate', 'lang' => :en)
    grid2 = @client.post('/puzzle/collaborate', 'lang' => :en)
    
    grid1.should == grid2
    grid1.should be_a_grid_definition
    
  end
  
  it "should assign collaboration for matching languages" do

    @other = PuzzleClient.new
    @other.get('/puzzle/register')
    
    @client.get('/puzzle/register')
    @client.post('/puzzle/collaborate', 'lang' => :en)
    
    response = @other.post('/puzzle/collaborate', 'lang' => :fr)
    response.should == 'none'
    
    response = @client.post('/puzzle/collaborate', 'lang' => :en)
    response.should == 'none'
   
  end
  
  it "should return the same puzzle to a collaboration request, if some collaboration is running" do

    @other = PuzzleClient.new
    @other.get('/puzzle/register')
    
    @client.get('/puzzle/register')
    @client.post('/puzzle/collaborate', 'lang' => :en)
    
    @other.post('/puzzle/collaborate', 'lang' => :en)
    grid1 = @client.post('/puzzle/collaborate', 'lang' => :en)
    grid2 = @client.post('/puzzle/collaborate', 'lang' => :en)
    
    grid1.should == grid2
    
  end
  
  it "should return 'unsupported' if some collaborator asks for unknown languages" do
    
    @client.get('/puzzle/register')
    response = @client.post('/puzzle/collaborate', 'lang' => :marchy)
    
    response.should == 'unsupported'
    
  end
  
  it "should queue and pass mouse events to collaborator" do
    
    start_collaboration
    
    @client.post('/puzzle/event', {'event' => 'md;1;1'})
    @other.get('/puzzle/consume').should == 'md;1;1'
    @client.post('/puzzle/event', {'event' => 'mm;1;2'})
    @other.get('/puzzle/consume').should == 'mm;1;2'
    @client.post('/puzzle/event', {'event' => 'mm;1;3'})
    @other.get('/puzzle/consume').should == 'mm;1;3'
    @client.post('/puzzle/event', {'event' => 'mu;1;4'})
    @other.get('/puzzle/consume').should == 'mu;1;4'
    @client.post('/puzzle/event', {'event' => 'found;Hello'})    
    @other.get('/puzzle/consume').should == 'found;Hello'
    
  end
  
  it "should send a batch of pending events to collaborator" do
        
    start_collaboration
    
    @client.post('/puzzle/event', {'event' => 'md;1;1'})
    @client.post('/puzzle/event', {'event' => 'mm;1;2'})
    @client.post('/puzzle/event', {'event' => 'mm;1;3'})
    @client.post('/puzzle/event', {'event' => 'mu;1;4'})
    @client.post('/puzzle/event', {'event' => 'found;Hello'})
    
    @other.get('/puzzle/consume').should == "md;1;1\n" + "mm;1;2\n" + "mm;1;3\n" + "mu;1;4\n" + 'found;Hello'
    
  end
  
  it "should return none when no event is available" do
    
    start_collaboration
    
    @other.get('/puzzle/consume').should == 'none'
    
  end
  
  it "should empty event queue when collaborator disconnects" do
    
    start_collaboration
    
    @client.post('/puzzle/event', {'event' => 'md;1;1'})
    @client.post('/puzzle/event', {'event' => 'mm;1;2'})
    @client.post('/puzzle/event', {'event' => 'mm;1;3'})
    @client.post('/puzzle/event', {'event' => 'mu;1;4'})
    
    @client.get('/puzzle/unregister')
    
    @other.get('/puzzle/consume').should == 'broken'
    
  end
  
  it "should return 'none' if a non collaborating user asks for events" do

    @client.get('/puzzle/register')
    @client.get('/puzzle/consume').should == 'none'
    
  end
  
  it "should return 'error' if a non collaborating user sends an event" do

    @client.get('/puzzle/register')
    @client.post('/puzzle/event', {'event' => 'md;1;1'}).should == 'error'
    
  end
  
  def start_collaboration
    
    @other = PuzzleClient.new
    @other.post('/puzzle/register')
    
    @client.get('/puzzle/register')
    @client.post('/puzzle/collaborate', 'lang' => :en)
    
    @other.post('/puzzle/collaborate', 'lang' => :en)
    @client.post('/puzzle/collaborate', 'lang' => :en)
    
  end
  
  def be_a_grid_definition
    GridDefinition.new
  end
  
  def show_help_tip response
    puts "Did you start the server with less than 2 seconds timeout?" if response == 'love'
  end
  
end

class GridDefinition
    
    def matches?(res)
      
      @full = res
      @short = res if res.length <= 20
      @short = res[0...20] + "..." if res.length > 20
      
      grid = PuzzleClient.create_grid(res)
      
      @error = grid.error
      
      grid.valid?
      
    end
    
    def failure_message
      "expected '#{@short}' to be a grid definition\n  #{@error}\nWas: [#{@full}]"
    end
    
    def negative_failure_message
      "expected '#{@short}' not to be a grid definition"
    end
    
end
