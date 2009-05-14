#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'puzzle_client'

describe 'New grid-message validation' do
  
  it "should accept grid without words" do
    grid = PuzzleClient.create_grid "3;3;abcdefghi;"
    grid.should be_valid
  end
  
  it "should accept grid with words" do
    grid = PuzzleClient.create_grid "3;3;abcdefghi;max;false;0;0;0;1;0;2;no;false;1;0;1;2"
    grid.should be_valid
  end
  
  it "should reject invalid columns number" do
    grid = PuzzleClient.create_grid "az;3;abcdefghi;"
    grid.should_not be_valid
  end
  
  it "should reject invalid rows number" do
    grid = PuzzleClient.create_grid "3;-1;abcdefghi;"
    grid.should_not be_valid
  end
  
  it "should reject not enough characters" do
    grid = PuzzleClient.create_grid "3;3;abcdef;"
    grid.should_not be_valid
  end
  
  it "should reject too many characters" do
    grid = PuzzleClient.create_grid "3;3;zxabcdefghi;"
    grid.should_not be_valid
  end
  
  it "should reject missing reversed flag" do
    grid = PuzzleClient.create_grid "3;3;abcdefghi;max;false;0;0;0;1;0;2;no;1;0;1;2"
    grid.should_not be_valid
  end
  
  it "should reject messages with incomplete location for words" do
    grid = PuzzleClient.create_grid "3;3;abcdefghi;max;false;0;0;0;1;no;false;1;0;1;2"
    grid.should_not be_valid
    grid = PuzzleClient.create_grid "3;3;abcdefghi;max;false;0;0;0;1;0;2;no;false;1;2"
    grid.should_not be_valid
  end
  
  it "should reject negative locations" do
    grid = PuzzleClient.create_grid "3;3;abcdefghi;max;false;0;0;0;1;-2;2;no;false;1;0;1;2"
    grid.should_not be_valid
  end
  
  it "should reject too high locations" do
    grid = PuzzleClient.create_grid "3;3;abcdefghi;max;false;0;0;0;1;3;2;no;false;1;0;1;2"
    grid.should_not be_valid
  end
  
  it "does not check for words overlapping" do
    grid = PuzzleClient.create_grid "3;3;abcdefghi;max;false;0;0;0;1;0;2;no;false;0;0;0;1"
    grid.should be_valid
  end
  
end