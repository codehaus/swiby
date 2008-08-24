#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/form'
require 'test/manual/manual_test'

dir = File.dirname(__FILE__)
this_file = File.basename(__FILE__)

Dir.open(dir).each do |file|

  next if file == 'manual_test.rb'
  next unless file =~ /[.]rb$/ and file != this_file
  
  puts "Loading #{dir}/#{file}..."
  require "#{dir}/#{file}"
  
end

Defaults.auto_sizing_frame = true

class TestRunnerController
  
  def initialize
    @test_suites = ManualTest.suites
  end
  
  def view= view
    @view = view
  end
  
  def test_suites
    @test_suites
  end
  
  def change_test_suite suite
    
    cb_run = {}
    cb_result = {}
    
    @view[:detail].change_content {
        suite.each { |test|
          row
            cell
              cb_run[test] = check(test.executed?, :enabled => false)
            cell
              label test.description
            cell
              button("Test") { @controller.execute(test, cb_run[test], cb_result[test]) }
            cell
              cb_result[test] = check("Succeeded?", test.succeeded?, :enabled => false) { @controller.done(test, cb_result[test].selected?) }
              
        }
        
    }
    
  end
  
  def execute test, cb_run, cb_result
    
    @report = @view.find(:report) unless @report

    test.execute
    
    cb_run.selected = true
    
    cb_result.enabled = true
    cb_result.selected = false
    
    @report.text = report
    
  end
  
  def done test, result
    
    return unless test.executed?
    
    test.succeeded = result
    
    @report.text = report
    
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

end

runner = TestRunnerController.new

f = frame(:controller => runner) {
  
  width 550
  height 400
    
  title "Manual tests suite"
  
  content {
 
    west
      list(@controller.test_suites) { |suite| @controller.change_test_suite suite }

    center
      panel(:layout => :table, :hgap => 8, :vgap => 3, :name => :detail)
      
    south
      label @controller.report, :name => :report
      
  }
  
  visible true
  
}

Defaults.exit_on_frame_close = false
