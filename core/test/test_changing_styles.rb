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

require 'swiby/styles'

include Swiby

class TestStyles < Test::Unit::TestCase

  def setup

    @styles = create_styles {
      root(
        :font_family => Styles::VERDANA,
        :font_style => :normal,
        :font_size => 10
      )
      label(
        :font_style => :italic,
        :font_size => 12
      )
      input(
        :font_family => Styles::VERDANA,
        :font_style => :normal,
        :font_size => 14
      )
      button(
        :font_weight => :bold
      )
      a_class {
        label(
          :font_size => 3
        )
      }
    }

  end
  
  def test_setting_the_same_value_to_some_specific_style
    
    @styles.change!(:font_size, 21)
    
    assert_equal 21, @styles.root.font_size
    assert_equal 21, @styles.label.font_size
    assert_equal 21, @styles.input.font_size
    assert_equal 21, @styles.a_class.label.font_size
    
  end
  
  def test_setting_different_values_for_some_specific_style
    
    @styles.change!(:font_size) do |path, size|
      size + 7
    end
    
    assert_equal 17, @styles.root.font_size
    assert_equal 19, @styles.label.font_size
    assert_equal 21, @styles.input.font_size
    assert_equal 10, @styles.a_class.label.font_size
    
  end
  
  def test_setting_only_some_values
    
    @styles.change!(:font_size) do |path, size|
      
      if path == 'root'
        size + 3
      elsif path == 'a_class.label'
        size + 5
      end
      
    end
    
    assert_equal 13, @styles.root.font_size
    assert_equal 12, @styles.label.font_size
    assert_equal 14, @styles.input.font_size
    assert_equal 8, @styles.a_class.label.font_size
    
  end
  
end
