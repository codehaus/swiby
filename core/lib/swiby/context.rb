#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import java.util.Properties

class String
    
    # Searches for a text matching this +String+ in all the English bundles, to find a
    # key associated with it. Then, searches for the key in current language.
    # Text matching is not case sensitive.
    #
    # If some English bundle contains one or more special key starting with 'no_translate_pattern',
    # the value associated with the special key is used as an exclude from translation
    # matching pattern. The system does no translation for any text matching the pattern.
    # The pattern is used as a regular expression.
    #
    # Note: don't repeat the same key twice, only the second one is 'loaded'.
    #
    # When at least one bundle is loaded, if Swiby cannot find any tanslation it 
    # returns the same text prefixed with "MISSING", unless disabling translation missing
    # information
    #
    # This method is a shortcut to Swiby::CONTEXT.translate String
    #
    def translate
      Swiby::CONTEXT.translate self
    end
    
    # Applies the common String substitution made by Ruby in expressions like:
    #    "Hello #{name}"
    # using the given +binding+ to resolve the variables/execute the embedded expressions
    #
    # Used mainly with strings loaded from a resource bundle that are not handled by Ruby
    def apply_substitution binding
      eval('"' + self + '"', binding)
    end
    
end

class Symbol
  
    # Searches all the bundles for a text associated with +key+, in the current language.
    #
    # If the key does not exist returns the key as String
    #
    # This method is a shortcut to Swiby::CONTEXT.to_text Symbol
    #
    def to_text
      Swiby::CONTEXT.to_text self      
    end
    
    # Searches for the text associated to this symbol and then applies the substitution,
    # see String#apply_substitution
    #
    # The aim of the method is to add a shortuct, instead of writing code like
    #   puts :greeting.to_text.apply_substitution binding()
    # the code can be
    #   puts :greeting.apply_substitution binding()
    #
    def apply_substitution binding
      eval('"' + self.to_text + '"', binding)
    end
    
    # Like Symbol#to_text but returns a +String+ which is able to change the text using
    # this +Symbol+ value as key. Changes the String#translate method behavior.
    def dynamic_text binding = nil
      
      text = self.to_text
      
      if binding
        
        text = text.apply_substitution(binding)
        
        text.instance_variable_set(:@translation_binding, binding)
        
      end
      
      def text.translate
        @translation_key.dynamic_text @translation_binding
      end
      
      text.instance_variable_set(:@translation_key, self)
      
      text
      
    end
    
end

module Swiby

  class TranslationBundle
    
    attr_reader :name, :language
    attr_reader :no_translate_patterns

    def initialize name, language = :en
      
      raise "language parameter cannot be nil" unless language
      
      @name, @language = name, language
      
      @texts_by_key = {}
      @keys_by_texts = {}
      
      @no_translate_patterns = nil
      
    end
    
    def find key
      @texts_by_key[key]
    end
    
    def match text
      @keys_by_texts[text.downcase]
    end
    
    # Loads translations from a java properties formatted text file .
    # A UTF-8 text file, each line is a key followed by the '=' sign and
    # the associated text
    #
    # Notes:
    #   1) don't repeat the same key twice, only the second one is 'loaded'.
    #   2) IMPORTANT: be carefull not to create a UTF-8 with BOM file (byte order mark)
    #
    # Searches all directories found in Ruby's load path.
    #
    def load
      
      found = false
      file_path = nil
      file_name = "#{@name}_#{@language}.properties"
      
      $:.each do |path|
        
        next unless File.directory?(path)
        
        file_path = File.join(path, file_name)
        
        if File.exist?(file_path)
          found = true
          break
        end
        
      end
      
      raise "cannot load bundle with base name #{@name}, language #{@language}" unless found
      
      begin
        stream = java.io.FileInputStream.new(file_path)
        stream = java.io.InputStreamReader.new(stream, "utf-8")
      rescue
        raise "Cannot open bundle #{@name}, file #{file_path}"
      end
    
      bundle = Properties.new
      bundle.load(stream)
      
      stream.close
      
      keys = bundle.keys
      
      while keys.hasMoreElements
        
        key = keys.nextElement
        text = bundle.getProperty(key)
        
        if key =~ /^no_translate_pattern/
          @no_translate_patterns = [] unless @no_translate_patterns
          @no_translate_patterns << /#{text}/
        else
          add_text key, text
        end
        
      end
      
      self
    
    end
    
    def add_text key, text
      
      key = key.to_sym
      
      @texts_by_key[key] = text
      @keys_by_texts[text.downcase] = key if @language == :en
      
    end
    
  end
  
  class SwibyContext
  
    attr_accessor :language, :translations_enabled
    attr_accessor :missing_translation_enabled
    
    def initialize language = :en
      @language_change_listeners = []
      @language = language
      @bundles = {language => []}
      @translations_enabled = false
      @current_bundles = @bundles[language]
      @no_translate_patterns = []
      @missing_translation_enabled = true
    end
    
    def default_setup
      
      languages = []
      
      resource_name = "resource/#{File.basename($0, '.rb')}"
      
      file_pattern = "#{resource_name}_[a-z][a-z].properties"
      
      path = File.dirname($0)
        
      matching_files = Dir.glob("#{path}/#{file_pattern}")
        
      unless matching_files.empty?
        
        $: << path
        
        matching_files.each do |file|
          
          file =~ /#{resource_name}_([a-z][a-z]).properties/
          
          languages << $1.to_sym
          
        end
      
        add_translation_bundle resource_name, *languages
      
      end
      
    end
  
    def language= language
      
      @language = language
      @current_bundles = @bundles[language]
      
      raise "Language not supported: #{language}" unless @current_bundles
      
      fire_language_change
      
    end

    def add_language_change_listener listener
      @language_change_listeners << listener
    end

    def remove_language_change_listener listener
      @language_change_listeners.delete listener
    end

    def fire_language_change
      
      @language_change_listeners.each do |listener|
        listener.language_changed
      end
      
    end
    
    # +bundle_name+ either a string, used as a resource bundle name (see java.util.Properties)
    # for the given +language+ or the current language, either a bundle +TranslationBundle+ object
    # and the +language+ parameter is useless (raises an error if +language+ is not nil)
    #
    # +language+ can be an array of languages
    #
    # Note: the current implementation does not use the default bundle mecanism from Java because 
    # changing the path where bundles are seached fails.
    #
    def add_translation_bundle bundle_name, *language
      
      if bundle_name.is_a?(String)
        
        language << @language if language.empty?
    
        language.each do |lang|
          
          bundle = TranslationBundle.new(bundle_name, lang).load
          
          self.add_translation_bundle bundle
          
        end
        
      elsif bundle_name.is_a?(TranslationBundle)
        
        raise "cannot set language parameter when using a TranslationBundle" unless language.empty?
        
        tb = bundle_name
        
        language_bundles = @bundles[tb.language]
        
        unless language_bundles
          language_bundles = []
          @bundles[tb.language] = language_bundles
        end
      
        already_registered = language_bundles.any? {|bundle| bundle.name == tb.name}
        
        unless already_registered
          
          language_bundles << tb
          
          @no_translate_patterns.concat(tb.no_translate_patterns) if tb.no_translate_patterns
          
        end
        
      else
        raise "Expected a String or a TranslationBundle but got a #{bundle_name.class} - #{bundle_name}"
      end
      
      @translations_enabled = true
      
    end
  
    # Searches all the bundles for a text associated with +key+, in the current language.
    #
    # If the key does not exist returns the key as String
    #
    def to_text key
      
      return key unless @translations_enabled

      @current_bundles.reverse_each do |bundle|
      
        value = bundle.find(key)
        
        return value if value
        
      end
      
      key
        
    end
    
    # Searches for a text matching +text+ in the all English bundles, to find a
    # key associated with it. Then, searches for the key in current language.
    # Text matching is not case sensitive.
    #
    # If some English bundle contains one or more special key starting with 'no_translate_pattern',
    # the value associated with the special key is used as an exclude from translation
    # matching pattern. The system does no translation for any text matching the pattern.
    # The pattern is used as a regular expression.
    #
    # Note: don't repeat the same key twice, only the second one is 'loaded'.
    #
    # When at least one bundle is loaded, if Swiby cannot find any tanslation it 
    # returns the same text prefixed with "MISSING", unless disabling translation missing
    # information
    #
    def translate text

      text = text.to_s
      
      return text unless @translations_enabled
      
      @no_translate_patterns.each do |pattern|
        return text if text =~ pattern
      end
      
      key = nil
      
      en_bundles = @bundles[:en]
      
      en_bundles.reverse_each do |bundle|
        
        key = bundle.match(text)
        
        break if key
        
      end
      
      if key
        to_text(key)
      elsif ! @missing_translation_enabled
        text
      else
        "MISSING #{text}"
      end
      
    end
      
  end

  SWIBY_VERSION = '1.0'
  
  CONTEXT = SwibyContext.new
  
end

require 'swiby/swing'
require "swiby_ext-#{Swiby::SWIBY_VERSION}.jar"

