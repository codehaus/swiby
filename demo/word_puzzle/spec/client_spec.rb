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

describe PuzzleClient do

  attr_accessor :was_processed
  
  attr_accessor :md_processed, :mv_processed, :mu_processed, :wf_processed 
  attr_accessor :col_pos
    
  before :each do
    
    @server = PuzzleServer.new(2)
    @server.start true
    
    start_collaboration
    
    @was_processed = false
    
  end
  
  after :each do
    @client.unregister
    @other.unregister
    @server.stop
  end
  
  it "should call mouse down handler" do
    
    @other.fire_mouse_down 1, 5
    
    example = self
    
    @client.consume do
    
      @example = example
      
      def mouse_down row, col
        
        row.should == 1
        col.should == 5
        
        @example.was_processed = true
        
      end
      
    end
    
    @was_processed.should be_true
    
  end
  
  it "should call mouse up handler" do
    
    @other.fire_mouse_up 1, 5
    
    example = self
    
    @client.consume do
    
      @example = example
      
      def mouse_up row, col
        
        row.should == 1
        col.should == 5
        
        @example.was_processed = true
        
      end
      
    end
    
    @was_processed.should be_true
    
  end
  
  it "should call mouse move handler" do
    
    @other.fire_mouse_move 1, 5
    
    example = self
    
    @client.consume do
    
      @example = example
      
      def mouse_move row, col
        
        row.should == 1
        col.should == 5
        
        @example.was_processed = true
        
      end
      
    end
    
    @was_processed.should be_true
    
  end
  
  it "should call word found handler" do
    
    @other.fire_found 'hello'
    
    example = self
    
    @client.consume do
    
      @example = example
      
      def word_found word
        
        word.should == 'hello'
        
        @example.was_processed = true
        
      end
      
    end
    
    @was_processed.should be_true
    
  end
  
  it "should call every handler if it receives a batch of events" do
    
    @other.fire_mouse_down 1, 5
    @other.fire_mouse_move 1, 6
    @other.fire_mouse_move 1, 7
    @other.fire_mouse_move 1, 8
    @other.fire_mouse_up 1, 9
    @other.fire_found 'hello'
    
    @md_processed = 0
    @mv_processed = 0
    @mu_processed = 0
    @wf_processed = 0
    
    @col_pos = 5
    
    example = self
    
    @client.consume do
    
      @example = example
      
      def mouse_down row, col
        row.should == 1
        col.should == @example.col_pos
        @example.md_processed += 1
        @example.col_pos += 1
      end
      
      def mouse_up row, col
        row.should == 1
        col.should == @example.col_pos
        @example.mu_processed += 1
        @example.col_pos += 1
      end
      
      def mouse_move row, col
        row.should == 1
        col.should == @example.col_pos
        @example.mv_processed += 1
        @example.col_pos += 1
      end
      
      def word_found word
        word.should == 'hello'
        @example.wf_processed += 1
      end
      
    end
    
    @md_processed.should == 1
    @mv_processed.should == 3
    @mu_processed.should == 1
    @wf_processed.should == 1
    
  end
  
  it "should break connection if it asks for a new grid" do
    
    @client.should be_collaborating
    
    @client.new_grid
    
    @client.should_not be_collaborating
    
    example = self
    
    @other.consume do
      
      @example = example
      
      def broken
        @example.was_processed = true
      end
      
    end
    
    @was_processed.should be_true
    
  end
  
  it "should send heartbeats to keep session alive" do
    
    @client.register.should == 'love'
    
    sleep 3
    
    @client.register.should == 'love'
    
  end
  
  def start_collaboration
    
    @client = PuzzleClient.new(0.1)
    @client.register
    
    @other = PuzzleClient.new
    @other.register
    
    @client.collaborate
    
    @other.collaborate
    @client.collaborate
    
  end
  
end