#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'swiby/util/developer'

class TestMergeOptions < Test::Unit::TestCase
  
  def test_options_is_a_hash
    
    options = merge_defaults!({}, :name => 'James', :color => :white)
    
    assert_equal 2, options.size
    assert_equal 'James', options[:name]
    assert_equal :white, options[:color]
    
  end
  
  def test_options_contains_some_keys
    
    options = merge_defaults!({:name => 'Nobody'}, :name => 'James', :color => :white)
    
    assert_equal 2, options.size
    assert_equal 'Nobody', options[:name]
    assert_equal :white, options[:color]
        
  end
  
  def test_options_is_an_empty_array
    
    options = merge_defaults!([], :name => 'James', :color => :white)
    
    assert_equal 1, options.size
    assert_kind_of Hash, options[0]
    assert_equal 'James', options[0][:name]
    assert_equal :white, options[0][:color]
        
  end
  
  def test_options_is_an_array
    
    options = merge_defaults!([2, 'hello', {:test => 3}], :name => 'James', :color => :white)
    
    assert_equal 3, options.size
    assert_kind_of Hash, options[2]
    assert_equal 3, options.last[:test]
    assert_equal 'James', options.last[:name]
    assert_equal :white, options.last[:color]
        
  end
  
  def test_updates_hash
    
    options = {:test => 3, :name => 'James'}
    
    merge_defaults!(options, :color => :white, :test => 1)
    
    assert_equal 3, options.size
    assert_equal 3, options[:test]
    assert_equal 'James', options[:name]
    assert_equal :white, options[:color]
        
  end
  
end