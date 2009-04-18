#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby

  class WindowForTest
    
    attr_reader :was_closed, :did_exit
    
    def close
      @was_closed = true
    end

    def exit
      close
      @did_exit = true
    end
    
  end

  class TestViewDefinition
    
    def instantiate controller
    end
    
  end

  def self.test_controller controller
    
    controller.instance_variable_set :@window, WindowForTest.new
    
    def controller.view_was_closed?
      @window.was_closed
    end
    
    def controller.did_exit_application?
      @window.did_exit
    end
    
    controller
    
  end

  # define a dummy view definition, registers it with the given name for later retrieval
  # it does not open any window when it instantiates the view
  # returns the definition
  def self.define_test_view name
    
    test_view_def = TestViewDefinition.new
    
    ViewDefinition.definitions[name] = test_view_def
    
    test_view_def
    
  end
  
end