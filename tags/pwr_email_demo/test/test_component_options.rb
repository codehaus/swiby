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
require 'swiby/core'

module Swiby

  class ComponentOptionTestCase < Test::Unit::TestCase
    
    def gui_wrapper?
      true
    end
    
    def run(*args) #:nodoc:
      return if @method_name.to_s == "default_test"
      super
    end
    
  end
  
  ##-----
  class TestNoArgsInitializer < ComponentOptionTestCase
    
    class TestOptions < ComponentOptions

      define "Test" do

        declare :label, [String, Symbol], true
        declare :text, [String, Symbol]
        declare :height, [Integer], true
        declare :width, [Integer], true

      end

    end

    def test_invalid_number_arguments_raises_error
      
      ex = assert_raise ArgumentError do
        TestOptions.new self, "Name"
      end
      
      assert_equal ComponentOptions.bad_signature_error('Test', String), ex.message
      
    end

    def test_missing_required_option_raises_error
      
      ex = assert_raise ArgumentError do
        TestOptions.new self, :label => "Name"
      end
      
      assert_equal ComponentOptions.missing_option_error('Test', :text), ex.message
      
    end

    def test_all_options_in_hash
      
      x = TestOptions.new(self, :label => "Name", :text => "James")
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]
      
    end

    def test_all_options_set_by_block
      
      x = TestOptions.new(self) do
        label "Name"
        text "James"
      end
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]
      
    end
    
    def test_accepts_more_option
      
      x = TestOptions.new self, :more_options do
        label "Name"
        text "James"
      end
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]
      
    end

    def test_incompatible_options_in_hash
      
      ex = assert_raise ArgumentError do
        TestOptions.new(self, :label => "Name", :text => "James", :width => "200")
      end
      
      assert_equal ComponentOptions.invalid_argument(:width, {:width => "200"}, [Integer]), ex.message

    end

  end

  ##-----
  class TestOneArgInitializer < ComponentOptionTestCase
  
    class TestOptions < ComponentOptions

      define "Test" do

        declare :label, [String, Symbol], true
        declare :text, [String, Symbol]
        declare :height, [Integer], true
        declare :width, [Integer], true

        overload :text

      end

    end

    def test_invalid_number_arguments_raises_error
      
      ex = assert_raise ArgumentError do
        TestOptions.new self, "Name", 33
      end
      
      assert_equal ComponentOptions.bad_signature_error('Test', String, Fixnum), ex.message
      
    end
    
    def test_invalid_arguments_raises_error
      
      ex = assert_raise ArgumentError do
        TestOptions.new self, 44
      end
      
      assert_equal ComponentOptions.bad_signature_error('Test', Fixnum), ex.message
      
    end

    def test_missing_required_option_raises_error
      
      ex = assert_raise ArgumentError do
        TestOptions.new self, :label => "Name"
      end
      
      assert_equal ComponentOptions.missing_option_error(:text), ex.message
      
    end

    def test_missing_required_option_raises_error
      
      ex = assert_raise ArgumentError do
        TestOptions.new self, :label => "Name"
      end
      
      assert_equal ComponentOptions.missing_option_error('Test', :text), ex.message
      
    end

    def test_resolve_init_call_arguments
      
      x = TestOptions.new(self, "James")
      
      assert_equal "James", x[:text]
      
    end

    def test_all_options_set_by_block
      
      x = TestOptions.new self do
        label "Name"
        text "James"
      end
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]
      
    end
    
    def test_accepts_more_option
      
      x = TestOptions.new self, :more_options do
        label "Name"
        text "James"
      end
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]
      
    end
    
    def test_accepts_more_option_after_arguments
      
      x = TestOptions.new self, "James", :more_options do
        label "Name"
      end
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]
      
    end

    def test_block_options_overrides_arguments
      
      x = TestOptions.new self, "James", :more_options do
        label "Name"
        text "Secret"
      end
      
      assert_equal "Name", x[:label]
      assert_equal "Secret", x[:text]
      
    end

    def test_incompatible_options_in_hash
      
      ex = assert_raise ArgumentError do
        TestOptions.new(self, :label => "Name", :text => "James", :width => "200")
      end
      
      assert_equal ComponentOptions.invalid_argument(:width, {:width => "200"}, [Integer]), ex.message

    end

  end
  
  ##-----
  class TestManyArgsInitializer < ComponentOptionTestCase
  
    class TestOptions < ComponentOptions

      define "Test" do

        declare :label, [String, Symbol], true
        declare :text, [String, Symbol]
        declare :height, [Integer], true
        declare :width, [Integer], true

        overload :text
        overload :width
        overload :label, :text
        overload :label, :text, :width, :height

      end

    end

    def test_invalid_number_arguments_raises_error
      
      ex = assert_raise ArgumentError do
        TestOptions.new self, Class
      end
      
      assert_equal ComponentOptions.bad_signature_error('Test', Class), ex.message
      
    end

    def test_missing_required_option_raises_error
      
      ex = assert_raise ArgumentError do
        TestOptions.new self, :label => "Name"
      end
      
      assert_equal ComponentOptions.missing_option_error('Test', :text), ex.message
      
    end

    def test_all_options_in_hash
      
      x = TestOptions.new(self, :label => "Name", :text => "James", :width => 200)
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]
      assert_equal 200, x[:width]
      
    end

    def test_incompatible_options_in_hash
      
      ex = assert_raise ArgumentError do
        TestOptions.new(self, :label => "Name", :text => "James", :width => "200")
      end
      
      assert_equal ComponentOptions.invalid_argument(:width, {:width => "200"}, [Integer]), ex.message

    end

    def test_arguments_only_call
      
      x = TestOptions.new(self, "Name", "James")
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]

    end

    def test_arguments_and_option_block
      
      x = TestOptions.new(self, "Name", "James", :more_options) do
        width 200
      end
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]
      assert_equal 200, x[:width]

    end

    def test_call_with_action_block
      
      x = TestOptions.new(self, "Name", "James") do
        :action_block
      end
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]
      assert_equal :action_block, x[:action].call

    end

    def test_one_argument_call_defaults_to_required
      
      x = TestOptions.new(self, "James")
      
      assert_equal "James", x[:text]

    end

    def test_one_argument_and_hash
      
      x = TestOptions.new(self, "James", :label => "Name", :width => 200)
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]
      assert_equal 200, x[:width]

    end

    def test_more_options_only
      
      x = TestOptions.new(self, :more_options) do
        text "James"
        label "Name"
        width 200
      end
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]
      assert_equal 200, x[:width]

    end

  end
  
  ##-----
  class TestArgsWithTypeAmbiguity < ComponentOptionTestCase
  
    class TestOptions < ComponentOptions

      define "Test" do

        declare :label, [String, Symbol], true
        declare :text, [String, Symbol], true
        declare :height, [Integer], true
        declare :width, [Integer], true

        overload :text
        overload :label
        overload :width

      end

    end

    def test_no_ambiguity
      
      x = TestOptions.new(self, 120)
      
      assert_equal 120, x[:width]

    end

    def test_if_ambiguity_use_declaration_order
      
      x = TestOptions.new(self, "James")
      
      assert_equal "James", x[:text]

    end

  end
  
  ##-----
  class TestArgsWithNilsInitializer < ComponentOptionTestCase
  
    class TestOptions < ComponentOptions

      define "Test" do

        declare :label, [String, Symbol], true
        declare :text, [String, Symbol], true
        declare :height, [Integer], true
        declare :width, [Integer], true

        overload :text
        overload :width
        overload :label, :text
        overload :label, :text, :width, :height

      end

    end

    def test_leading_nil_arguments_omitted
      
      x = TestOptions.new self, nil, "James"
      
      assert_nil x[:label]
      assert_equal "James", x[:text]

    end

    def test_trailing_nil_arguments_omitted
      
      x = TestOptions.new self, "Name", "James", nil, nil
      
      assert_equal "Name", x[:label]
      assert_equal "James", x[:text]

    end

    def test_nil_arguments_omitted
      
      x = TestOptions.new self, nil, "James", nil, nil
      
      assert_equal "James", x[:text]

    end

    def test_trailing_nil_arguments_omitted
      
      x = TestOptions.new self, 200, nil, nil
      
      assert_equal 200, x[:width]

    end

    def test_option_block_and_nil_args
      
      x = TestOptions.new self, 200, :more_options, nil do
        text "James"
      end
      
      assert_equal 200, x[:width]
      assert_equal "James", x[:text]

    end

  end
  
  ##-----
  class TestNoRequiredArg < ComponentOptionTestCase
  
    class TestOptions < ComponentOptions

      define "Test" do

        declare :name, [String, Symbol], true
        declare :text, [Object], true
        declare :height, [Integer], true
        declare :width, [Integer], true

        overload :text

      end

    end

    def test_accept_no_explicit_arg
      
      x = TestOptions.new(self, {:name => :phone})
      
      assert_equal :phone, x[:name]

    end

    def test_first_argument_is_required
      
      ex = assert_raise ArgumentError do
        TestOptions.new
      end
      
      assert_equal ComponentOptions.missing_component_error('Test'), ex.message

    end

    def test_complain_if_first_argument_is_not_component
      
      ex = assert_raise ArgumentError do
        TestOptions.new('Hello')
      end
      
      assert_equal ComponentOptions.not_a_component_error('Test', 'Hello'), ex.message

    end
    
  end
  
end