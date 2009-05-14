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
require 'swiby/data'

class TestTypedNil < Test::Unit::TestCase

  def test_normal_instances_are_unchanged
    
    james = James.new
    
    assert_not_equal 'nil', James.new.inspect
    
    assert !james.respond_to?(:method_missing)
    assert james.respond_to?(:first)
    assert james.respond_to?(:hello)
    
  end

  def test_nil_instance_has_same_API
    
    james_nil = James.nil_instance
    
    assert_equal 'nil', james_nil.inspect
    
    assert james_nil.respond_to?(:method_missing)
    assert james_nil.respond_to?(:first)
    assert james_nil.respond_to?(:hello)
    
  end

  def test_keeps_desired_class_hierarchy_API
    
    assert_equal nil.hash, James.nil_instance.hash_value
    
    assert_raise NoMethodError do
      James.nil_instance.i_do_not_exist
    end
    
  end
  
  def test_nil_instance_belongs_to_original_class
    assert_equal James, James.nil_instance.class
  end

  def test_nil_instance_behaves_like_nil
    assert James.nil_instance.nil?
    assert James.nil_instance == nil
    assert James.nil_instance.hash == nil.hash
    assert James.nil_instance.equal?(nil)
  end

  def test_unfortunately_nil_instance_is_not_nil
    assert James.nil_instance
  end
  
  def test_nil_instance_behaves_as_normal_object
    assert_equal 'James', James.nil_instance.first
    assert_equal 'James', James.new.first
  end
  
  def test_nil_instance_behaves_as_differently_if_needed
    assert_nil James.nil_instance.hello
    assert_equal 'My name is Bond. James Bond!', James.new.hello
  end
  
end

class Ghost
  def i_do_not_exist
    '.no.'
  end
end

class Base < Ghost
  
  def hash_value
    hash
  end
  
end

class Name < Base
  attr_accessor :first, :last
end

class James < Name

  def initialize
    @first, @last = 'James', 'Bond'
  end
  
  def hello
    self.nil? ? nil : "My name is Bond. #{first} #{last}!"
  end
  
  define_typed_nil Base
  
end
