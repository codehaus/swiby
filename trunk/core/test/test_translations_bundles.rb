#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), 'data')

require 'test/unit'
require 'swiby/context'

class TestTranslations < Test::Unit::TestCase

  def setup
    
    @context = SwibyContext.new
    
    @context.add_translation_bundle 'translations_test'
    @context.add_translation_bundle 'translations_test', :fr
    
  end
  
  def test_seach_by_key
    assert_equal 'Hello', @context.to_text(:hello)
  end
  
  def test_translate_english_text_to_english
    assert_equal 'Hello', @context.translate('hello')
  end

  def test_change_language_and_seach_by_key
    @context.language = :fr
    assert_equal 'Salut', @context.to_text(:hello)
  end
  
  def test_translate_english_text_to_french
    @context.language = :fr
    assert_equal 'Salut', @context.translate('hello')
  end
  
  def test_bundle_not_found
    
    context = SwibyContext.new
    
    assert_raise RuntimeError do
      context.add_translation_bundle 'should_not_exist'
    end
    
  end
  
  def test_key_not_found
    assert_equal :unknown_key, @context.to_text(:unknown_key)
  end
  
  def test_key_not_found_in_another_language
    @context.language = :fr
    assert_equal :unknown_key, @context.to_text(:unknown_key)
  end
  
  def test_translation_not_found
    assert_equal 'MISSING Unknown text', @context.translate('Unknown text')
  end
  
  def test_translation_not_found_in_another_language
    @context.language = :fr
    assert_equal 'MISSING Unknown text', @context.translate('Unknown text')
  end
  
  def test_string_format_is_utf8_encoded
    @context.language = :fr
    assert_equal "départ".to_utf8, @context.to_text(:start)
  end
  
  def test_defaults_to_key_when_no_is_bundle_loaded
    context = SwibyContext.new
    assert_equal :bye, context.to_text(:bye)
  end
  
  def test_returns_text_when_no_is_bundle_loaded
    context = SwibyContext.new
    assert_equal 'bye', context.translate('bye')
  end
  
  def test_does_not_translate_if_text_matches_special_no_translate_key
    
    assert_equal 'A', @context.translate('A')
    assert_equal 'G', @context.translate('G')
    
    assert_equal 'main.rb', @context.translate('main.rb')
    
  end
  
end

class TestSymboAndStringTranslationsIntegration < Test::Unit::TestCase
  
  def setup
    Swiby::CONTEXT.add_translation_bundle 'translations_test', :en, :fr
  end
  
  def test_translates_and_substitute
    
    name = 'James'
    
    Swiby::CONTEXT.language = :en
    assert_equal 'Hello James!', :greeting.apply_substitution(binding)
    
    Swiby::CONTEXT.language = :fr
    assert_equal 'Bonjour James!', :greeting.apply_substitution(binding)
    
  end
  
  def test_dynamic_texts_translate_automatically
    
    Swiby::CONTEXT.language = :en
    start_en = :start.dynamic_text
    
    Swiby::CONTEXT.language = :fr
    start_fr = start_en.translate
    
    assert_equal 'start', start_en
    assert_equal 'départ'.to_utf8, start_fr
    
  end
  
  def test_dynamic_texts_keep_variables_scope

    name = 'Amanda'
    
    Swiby::CONTEXT.language = :en
    hello_en = :greeting.dynamic_text(binding)
    
    assert_equal 'Hello Amanda!', hello_en
    
    name = 'Octavia'
    
    hello_en = hello_en.translate
    
    Swiby::CONTEXT.language = :fr
    hello_fr = hello_en.translate
    
    assert_equal 'Hello Octavia!', hello_en
    assert_equal 'Bonjour Octavia!', hello_fr
    
  end

end