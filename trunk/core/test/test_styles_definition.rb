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
    }

  end

  def test_access_properties

    assert_equal 12, @styles.label.font_size
    assert_equal :italic, @styles.label.font_style

  end

  def test_access_properties_with_hash

    l = @styles.label

    assert_equal 12, l[:font_size]
    assert_equal :italic, l[:font_style]

  end

  def test_access_root_properties

    assert_equal 10, @styles.root.font_size
    assert_equal :normal, @styles.root.font_style

  end

  def test_missing_property_is_nil
    assert_nil @styles.label.font_family
    assert_nil @styles.label.james
  end

  def test_property_with_custom_class

    @styles.merge! {
      my_styles {
        label(:font_family => Styles::COURIER)
      }
    }

    name = @styles[:my_styles].label.font_family

    assert_equal Styles::COURIER, name

  end

  def test_property_with_custom_class_alternate_syntax

    @styles.merge! {
      my_styles {
        label(:font_family => Styles::COURIER)
      }
    }

    name = @styles.my_styles.label.font_family

    assert_equal Styles::COURIER, name

  end

  def test_argument_error_if_style_class_not_found

    assert_raise ArgumentError do
      @styles[:my_styles].label.font_family
    end

    assert_raise ArgumentError do
      @styles.my_styles #.label.font_family
    end

  end

  def test_argument_error_if_element_with_custom_class_not_found

    @styles.merge! {
      my_styles {
      }
    }

    assert_raise ArgumentError do
      assert_nil @styles[:my_styles].label
    end
    
    assert_raise ArgumentError do
      assert_nil @styles.my_styles.label
    end
    

  end

  def test_root_property_in_style_class

    @styles.merge! {
      my_styles {
        root(
          :font_style => :italic
        )
      }
    }

    assert_equal :italic, @styles[:my_styles].root.font_style
    assert_equal :italic, @styles.my_styles.root.font_style

  end

  def test_exist_for_existing_style_class

    @styles.merge! {
      my_styles {
      }
    }
    
    assert @styles.has_class?(:my_styles)

  end

  def test_exist_for_unkown_style_class
    assert !@styles.has_class?(:my_styles)
  end

  def test_exist_style_class_distinct_from_element
    assert !@styles.has_class?(:root)
  end

  def test_exist_element
    assert @styles.has_element?(:root)
  end

  def test_element_does_not_exist
    assert !@styles.has_element?(:combo)
  end

  def test_exist_element_distinct_from_style_class

    @styles.merge! {
      my_styles {
      }
    }

    assert !@styles.has_element?(:my_styles)
    
  end

  def test_exist_element_in_class

    @styles.merge! {
      my_styles {
        root(
          :font_style => :italic
        )
      }
    }

    assert @styles[:my_styles].has_element?(:root)
    
  end

  def test_merge_styles

    @styles.merge! {
      root(
        :color => :black
      )
    }
    
    assert_equal :normal, @styles.root.font_style
    assert_equal :black, @styles.root.color
        
  end
  
  def test_merge_styles_with_style_class

    @styles.merge! {
      my_styles {
        root(
          :font_style => :italic
        )
      }
    }

    @styles.merge! {
      my_styles {
        root(
          :font_size => 10
        )
      }
    }
    
    assert_equal :italic, @styles[:my_styles].root.font_style
    assert_equal 10, @styles[:my_styles].root.font_size
    
  end
  
end
