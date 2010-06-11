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

require 'swiby/util/ruby_tokenizer'

class TestRubyTokenizer < Test::Unit::TestCase

  def test_empty_script
    
    script = ""
    
    tokens = RubyTokenizer.tokenize(script)
    
    assert_equal 0, tokens.length
    
  end

  def test_all_type_of_comments
    
    script = <<SRC
=begin 
first
=end
\# comment 1
=begin any
=end
=begin
    begin comment
=end
\# comment 2
SRC
    
    expected = [[0, 18], [19, 11], [31, 15], [47, 29], [77, 11]]
    
    check_tokens script, :comment, expected
    
  end

  def test_find_strings
    
    script = <<SRC
x = "Hello"
fct("World")
puts 'Again'
SRC
    
    expected = [nil, [4, 7], nil, [16, 7], nil, [30, 7]]
    
    check_tokens script, :string, expected
    
  end


  def test_comment_without_end_of_line
    
    script = %{x = :max # Here is the comment}
    
    expected = [nil, nil, [9, 21]]
    
    check_tokens script, :comment, expected
    
  end

  def test_find_document_string
    
    script = "x = <<SRC\nI\nam\nyou\nSRC\ndone"
    
    expected = [nil, [4, 18], nil]
    
    check_tokens script, :string, expected
    
  end

  def test_does_not_confuse_document_string
    
    script = <<SRC
      each_address(name) {|address| ret << address}
SRC
    
    tokens = RubyTokenizer.tokenize(script)
    
    assert_equal 5, tokens.length
    
    names = ['each_address', 'name', 'address', 'ret', 'address']
    
    tokens.each_index do |i|
      assert_equal :name, tokens[i].type
      assert_equal names[i], tokens[i].value
    end
    
  end

  def test_find_symbols
    
    script = <<SRC
    x = :max
    y = :now
SRC
    
    expected = [nil, [8, 4], nil, [21, 4]]
    
    check_tokens script, :symbol, expected
    
  end

  def test_find_numbers
    
    script = <<SRC
    x = 56
    y = :now
SRC
    
    expected = [nil, [8, 2], nil, nil]
    
    check_tokens script, :number, expected
    
  end
  
  def test_unclosed_block_comment
    
    script = <<SRC
=begin
def max u = nil
  hello
end
SRC
    
    expected = [[0, 34]]
    
    check_tokens script, :comment, expected
    
  end
  
  def test_unclosed_string
    
    script = <<SRC
def max u = "nil
  hello = 34
end
SRC
    
    expected = [nil, nil, nil, [13, 3], nil, nil, nil]
    
    check_tokens script, :keyword, expected
    
  end

  def test_regular_expression
    
    script = <<SRC
# regexp
hello = /hel.*/
puts hello
SRC
    
    expected = [nil, nil, [17, 7], nil, nil]
    
    check_tokens script, :string, expected
    
  end

  def check_tokens script, type, expected
    
    tokens = RubyTokenizer.tokenize(script)
    
    assert_equal expected.length, tokens.length
    
    expected.each_index do |i|
      
      next unless expected[i]
      
      assert_equal type, tokens[i].type
      assert_equal expected[i][0], tokens[i].offset
      assert_equal expected[i][1], tokens[i].length
      
    end
    
  end
  
end

class TestNewLineSeparator < Test::Unit::TestCase
  
  def test_eof_is_nl
    
    script = %{#comment\nputs "Hi"\nx = 10}
    
    tokens = check_expected_tokens(script)
    
    assert_equal 0, tokens[0].offset
    assert_equal 8, tokens[0].length
    assert_equal 9, tokens[1].offset
    assert_equal 4, tokens[1].length
    assert_equal 14, tokens[2].offset
    assert_equal 4, tokens[2].length
    assert_equal 19, tokens[3].offset
    assert_equal 1, tokens[3].length
    assert_equal 23, tokens[4].offset
    assert_equal 2, tokens[4].length
    
  end
  
  def test_eof_is_cr
    
    script = %{#comment\rputs "Hi"\rx = 10}
    
    tokens = check_expected_tokens(script)
    
    assert_equal 0, tokens[0].offset
    assert_equal 8, tokens[0].length
    assert_equal 9, tokens[1].offset
    assert_equal 4, tokens[1].length
    assert_equal 14, tokens[2].offset
    assert_equal 4, tokens[2].length
    assert_equal 19, tokens[3].offset
    assert_equal 1, tokens[3].length
    assert_equal 23, tokens[4].offset
    assert_equal 2, tokens[4].length
    
  end
  
  def test_eof_is_cr_nl
    
    script = %{#comment\r\nputs "Hi"\r\nx = 10}
    
    tokens = check_expected_tokens(script)
    
    assert_equal 0, tokens[0].offset
    assert_equal 9, tokens[0].length
    assert_equal 10, tokens[1].offset
    assert_equal 4, tokens[1].length
    assert_equal 15, tokens[2].offset
    assert_equal 4, tokens[2].length
    assert_equal 21, tokens[3].offset
    assert_equal 1, tokens[3].length
    assert_equal 25, tokens[4].offset
    assert_equal 2, tokens[4].length

  end

  def check_expected_tokens script
    
    tokens = RubyTokenizer.tokenize(script)

    assert_equal 5, tokens.length
    
    assert_equal :comment, tokens[0].type
    assert_equal :name, tokens[1].type
    assert_equal :string, tokens[2].type
    assert_equal :name, tokens[3].type
    assert_equal :number, tokens[4].type

    tokens
    
  end
end