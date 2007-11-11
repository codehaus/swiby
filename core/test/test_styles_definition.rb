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

    styles {
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

  def teardown
    styles.clear
  end

  def test_access_properties

    assert_equal 12, styles.label.font_size
    assert_equal :italic, styles.label.font_style

  end

  def test_access_properties_with_hash

    l = styles.label

    assert_equal 12, l[:font_size]
    assert_equal :italic, l[:font_style]

  end

  def test_access_root_properties

    l = styles.root

    assert_equal 10, styles.root.font_size
    assert_equal :normal, styles.root.font_style

  end

  def test_missing_property_is_nil
    assert_nil styles.label.font_family
    assert_nil styles.label.james
  end

  def test_property_with_custom_class

    styles {
      my_styles {
        label(:font_family => Styles::COURIER)
      }
    }

    name = styles(:my_styles).label.font_family

    assert_equal Styles::COURIER, name

  end

  def test_property_with_custom_class_alternate_syntax

    styles {
      my_styles {
        label(:font_family => Styles::COURIER)
      }
    }

    name = styles.my_styles.label.font_family

    assert_equal Styles::COURIER, name

  end

  def test_runtime_error_if_style_class_not_found

    assert_raise RuntimeError do
      name = styles(:my_styles).label.font_family
    end

    assert_raise RuntimeError do
      name = styles.my_styles.label.font_family
    end

  end

  def test_missing_property_with_custom_class_is_nil

    styles {
      my_styles {
      }
    }

    assert_nil styles(:my_styles).label
    assert_nil styles.my_styles.label

  end

  def test_root_property_in_style_class

    styles {
      my_styles {
        root(
          :font_style => :italic
        )
      }
    }

    assert_equal :italic, styles(:my_styles).root.font_style
    assert_equal :italic, styles.my_styles.root.font_style

  end

  def test_exist_for_existing_style_class

    styles {
      my_styles {
      }
    }

    assert styles.exist?(:my_styles)

  end

  def test_exist_for_unkown_style_class
    assert !styles.exist?(:my_styles)
  end

end
