#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby'

require 'swiby/layout/table'

require 'swiby/mvc/frame'
require 'swiby/mvc/list'
require 'swiby/mvc/form'
require 'swiby/mvc/check'

require 'test/manual/manual_test'

Swiby::CONTEXT.missing_translation_enabled = false

limit_to = []
verbose = false

if ARGV[0]
  
  ARGV.each do |file|
    
    if file == '-v'
      verbose = true
    elsif file =~ /[.]rb$/
      limit_to << File.basename(file)
    else
      limit_to << File.basename(file + '.rb')
    end
    
  end
  
end

dir = File.dirname(__FILE__)
this_file = File.basename(__FILE__)

Dir.open(dir).each do |file|

  next if file == 'manual_test.rb'
  next unless file =~ /[.]rb$/ and file != this_file
  
  if limit_to.size > 0
    next unless limit_to.include?(file)
  end
  
  puts "Loading #{dir}/#{file}..." if verbose
  require "#{dir}/#{file}"
  
end

class TestRunnerController
  
  def test_suites= suite
    change_test_suite suite
  end
  
  def list_of_test_suites
    @test_suites = ManualTest.suites unless @test_suites
    @test_suites
  end
  
  def list_of_test_suites_changed?
    @test_suites.nil?
  end
  
  def report
    
    total = @test_suites.inject(0) { |sum, suite| sum + suite.count }
    success = @test_suites.inject(0) { |sum, suite| sum + suite.succeeded }
    executed = @test_suites.inject(0) { |sum, suite| sum + suite.executed }
    
    <<REPORT
<html>
<div style='font-family: sans-serif; font-size: 12; margin: 8 4'>
    #{total} tests, 
    <font color='green'>#{success} success,  
    <font color='red'>#{executed - success} failures
    (#{total - executed} untested)
</div>
REPORT

  end
  
  def change_test_suite suite

    cb_run = {}
    cb_result = {}
    
    controller = self
    
    @window[:detail].change_content {
        suite.each { |test|
          row
            cell
              cb_run[test] = check(test.executed?, :enabled => false)
            cell
              label test.description
            cell
              button("Test") { controller.execute(test, cb_run[test], cb_result[test]) }
            cell
              cb_result[test] = check("Succeeded?", test.succeeded?, :enabled => false) { controller.done(test, cb_result[test].selected?) }
              
        }
        
    }
    
  end
  
  def execute test, cb_run, cb_result
    
    begin
        test.execute
    rescue => err
      cb_result.enabled = false
      puts err.message, err.backtrace
    else
      cb_result.enabled = true
    end
    
    cb_run.selected = true
    
    cb_result.selected = false

    @master.refresh
    
  end
  
  def done test, result
    
    return unless test.executed?
    
    test.succeeded = result
    
    @master.refresh
    
  end
  
end

Defaults.auto_sizing_frame = true

f = frame(:controller => TestRunnerController.new) {
  
  width 550
  height 400
    
  title "Manual tests suite"
  
  west
    list :name => :test_suites

  center
    panel :layout => :table, :hgap => 8, :vgap => 3, :name => :detail

  south
    label :name => :report

  visible true
  
}

Defaults.exit_on_frame_close = false
