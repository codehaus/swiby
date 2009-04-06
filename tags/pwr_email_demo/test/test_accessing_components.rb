#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/swiby_unit'
require 'swiby/form'

include Swiby

class TestAccessByIndex < Test::Unit::TestCase

  include Unit

  def test_ordered_by_creation_order

    f = create_anonymous_form

    assert_equal 'section 1', f[0].text
    assert_equal 'label 0',   f[1].text
    assert_equal 'value 1',   f[2].value
    assert_equal 'section 2', f[3].text
    assert_equal 'label 2',   f[4].text
    assert_equal 'value 3',   f[5].value
    assert_equal 'section 3', f[6].text
    assert_equal 'button 4',  f[7].text
    assert_nil                f[8].text
    assert_equal 'label 5',   f[9].text
    assert_equal 'list 6',    f[10].value

  end

end

class TestAccessByIndex < Test::Unit::TestCase

  include Unit

  def test_ordered_by_creation_order

    f = create_anonymous_form

    assert_equal 'section 1', f[0].text
    assert_equal 'label 0',   f[1].text
    assert_equal 'value 1',   f[2].value
    assert_equal 'section 2', f[3].text
    assert_equal 'label 2',   f[4].text
    assert_equal 'value 3',   f[5].value
    assert_equal 'section 3', f[6].text
    assert_equal 'button 4',  f[7].text
    assert_nil                f[8].text
    assert_equal 'label 5',   f[9].text
    assert_equal 'list 6',    f[10].value

  end

end

class TestIterator < Test::Unit::TestCase

  include Unit

  def test_all_components

    f = create_anonymous_form

    count = 0

    f.each do |component|

      count += 1
      assert component.kind_of?(SwingBase)

    end

    assert_equal 11, count

  end

  def test_limit_to_specific_type

    f = create_anonymous_form

    count = 0

    f.each(SimpleLabel) do |component|

      count += 1
      assert component.kind_of?(SimpleLabel)

    end

    assert_equal 3, count

  end

end

class TestAccessByText < Test::Unit::TestCase

  include Unit

  def test_select_returns_duplicates

    f = create_same_values_form

    labels = f.select('label')
    
    assert_equal 3, labels.length

  end

  def test_select_returns_any_component_type

    f = create_same_values_form

    x = f.select('value')
    
    assert_equal 3, x.length
    
    assert_instance_of TextField, x[0]
    assert_instance_of TextField, x[1]
    assert_instance_of ComboBox, x[2]

  end

  def test_select_using_custom_condition

    f = create_same_values_form

    x = f.select do |comp|
      comp.instance_of?(ComboBox)
    end
    
    assert_equal 1, x.length
    
    assert_instance_of ComboBox, x[0]

  end

end


class TestLabelAndFieldLink < Test::Unit::TestCase

  include Unit

  def test_get_label_s_field

    f = create_anonymous_form

    assert_same f[2], f[1].linked_field
    assert_same f[5], f[4].linked_field
    assert_same f[10], f[9].linked_field

  end

  def test_get_field_s_label

    f = create_anonymous_form

    assert_same f[1], f[2].linked_label
    assert_same f[4], f[5].linked_label
    assert_same f[9], f[10].linked_label

  end

end

class TestAccessByName < Test::Unit::TestCase

  include Unit

  def test_name_set_explicitly

    f = create_explicit_names_form

    assert_equal 'v1', f[2].name
    assert_equal 'v2', f[4].name
    assert_equal 'b3', f[5].name
    assert_equal 'c4', f[8].name
    assert_equal 'l5', f[9].name
    
    assert_same f[2], f['v1']
    assert_same f[4], f['v2']
    assert_same f[5], f['b3']
    assert_same f[8], f['c4']
    assert_same f[9], f['l5']

  end

  def test_implicitly_by_symbol

    f = create_values_by_symbol_form

    assert_equal 'v1', f[2].name
    assert_equal 'v2', f[4].name
    #TODO implement accessor + symbol for buttons, lists and comboboxes
    #assert_equal 'b3', f[5].name
    #assert_equal 'c4', f[8].name
    #assert_equal 'l5', f[9].name
    
    assert_same f[2], f['v1']
    assert_same f[4], f['v2']
    #assert_same f[5], f['b3']
    #assert_same f[8], f['c4']
    #assert_same f[9], f['l5']
    
  end

  def test_implicitly_by_accessor_path

    f = create_values_by_accesor_path_form

    assert_equal 'v1', f[2].name
    assert_equal 'v2', f[4].name
    #TODO implement accessor + symbol for buttons, lists and comboboxes
    
    assert_same f[2], f['v1']
    assert_same f[4], f['v2']
    
  end
  
end
