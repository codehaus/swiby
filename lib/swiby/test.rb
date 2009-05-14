#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'test/unit'
require 'test/unit/failure'
require 'test/unit/ui/console/testrunner'
require 'test/unit/util/backtracefilter'

module Swiby
  
  @@all_gui_suites = []
  
  def gui_test_suite desc, &suite_block
    
    suite = GUITestSuite.new(desc)

    suite.instance_eval(&suite_block)
    
    @@all_gui_suites << suite
    
    suite
    
  end
  
  class GUITestSuite
    
    def initialize desc
      @desc = desc
      @all_tests = []
    end
    
    def window &window_factory
      @window_factory = window_factory
    end
    
    def test desc, &test
      
      raise "Missing 'window' factory statement" unless @window_factory
      
      test_def = GUITestDefinition.new(desc, @window_factory, &test)
      
      @all_tests << test_def
      
      class << test
        
        def method_missing(meth, *args, &block)
          @test_definition.add_step meth, block if block
          @test_definition.delegate meth, args unless block
        end
        
      end
      
      test.instance_variable_set :@test_definition, test_def
      test.instance_eval(&test)
      
    end
    
    def to_unit_suite
    
      suite = Test::Unit::TestSuite.new(@desc)
    
      @all_tests.each do |test_def|
        suite << test_def
      end

      suite
      
    end
  
  end
  
  class ApplicationWrapper
    
    include Test::Unit::Assertions
  
    def initialize test_result
      @test_result, @exited = test_result, false
    end
    
    def exit exit_code = 0
      @exited = true
    end
    
    def should_be_closed
      assert @exited, "did not exit application as expected"
    end
    
    def add_assertion
      @test_result.add_assertion
    end
    
  end
  
  class GUITestDefinition
    
    include Test::Unit::Util::BacktraceFilter
    
    attr_reader :description
    
    def initialize description, window_factory, &test_body
      @description = description
      @window_factory = window_factory
      @test_body  = test_body
      @test_steps = {}
    end

    def add_step name, body
      @test_steps[name] = body
    end
      
    def run test_result

      @window = @window_factory.call
      @application = ApplicationWrapper.new(test_result)
      
      @window[:application] = @application
      
      @test_result = test_result
      
      test_result.add_run
      
      begin
      
        @test_steps[:prepare].call if @test_steps[:prepare]
        @test_steps[:check].call if @test_steps[:check]
        
      rescue Test::Unit::AssertionFailedError => e
        test_result.add_failure(Test::Unit::Failure.new(@description, filter_backtrace(e.backtrace), e.message))
      rescue Exception => e
        test_result.add_error(Test::Unit::Error.new(@description, e))
      end
      
    end
  
    def size
      1
    end
    
    def delegate meth, args
      
      return @application if meth.to_s == 'application'
      
      component = @window if meth.to_s == 'view'
      component = @window.find(meth) unless component
      
      raise Exception, "Component not found '#{meth}'" unless component
      
      if args.length > 0
        
        #TODO what if < <cr> triggers field 'change'?
        component.java_component.grabFocus
          
          if component.respond_to?(:value=)
            component.value = *args
          elsif component.respond_to?(:text=)
            component.text = *args
          else
            #TODO what is the right alternative here
          end
        
        component.java_component.transferFocus
          
      end
      
      component.test_result = @test_result
      component
      
    end
    
  end
  
  module GuiTestMethods
    
    include Test::Unit::Assertions
  
    attr_accessor :test_result
    
    def should_be_enabled
      assert_block("'#{@component.name}' was not enabled") {@component.enabled}
    end
    
    def should_be_disabled
      assert_block("'#{@component.name}' was not disabled") {not @component.enabled}
    end
    
    def should_be_empty
      
      x = value_of_component
      
      message = "'#{@component.name}' was not empty, but '#{x}' instead"
      assert_block(message) {x.nil? || x.length == 0}
      
    end
    
    def should_be expected
      
      x = value_of_component
      
      message = "'#{@component.name}' expected <#{expected}> but was <#{x}>'"
      assert_block(message) {x == expected}
      
    end
    
    def should_match regexp
      
      x = value_of_component
      
      assert_match(regexp, x, "component '#{@component.name}'")
      
    end
    
    def should_be_closed
      assert_block("'#{@component.name}' was not closed") {!@component.is_visible?}
    end
    
    def add_assertion
      @test_result.add_assertion
    end
      
    def value_of_component
      if @component.respond_to?(:value)
        @component.value
      else
        @component.text
      end
    end
    
  end

  class SwingBase
    
    include GuiTestMethods
    
    def exit exit_code = 0
      self[:application].exit exit_code
    end
    
    
  end
  
  def self.run_all_tests

  suite_name = File.basename($0)[0...$0.length - File.extname($0).length]

  unit_suite = Test::Unit::TestSuite.new(suite_name)

    @@all_gui_suites.each do |gui_suite|
    
      unit_suite << gui_suite.to_unit_suite
    
    end
    
    runner = Test::Unit::UI::Console::TestRunner.new(unit_suite)
  
    runner.start
  
  end
  
end

at_exit do
  
  unless $!
    Swiby.run_all_tests
    exit
  end
  
end
