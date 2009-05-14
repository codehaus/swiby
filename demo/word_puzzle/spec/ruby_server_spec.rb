#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'spec/server_spec'
require 'puzzle_server'

describe "Ruby PuzzleServer" do
  
  it_should_behave_like "PuzzleServer"
  
  before :all do
    @server = PuzzleServer.new(2)
    @server.start true
  end
  
  after :all do
    @server.stop
  end
  
end