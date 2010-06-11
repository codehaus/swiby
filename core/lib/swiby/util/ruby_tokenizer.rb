#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'set'
require "stringio"

class Token
  
  attr_accessor :offset, :length, :type, :value

  def initialize offset, length, type, value
    @offset = offset
    @length = length
    @type = type
    @value = value
  end
  
  def to_s
    "#{type} (#{@offset}, #{@offset + @length - 1}) [#{@length}] = #{value}"
  end
  
end

class RubyTokenizer

  KEYWORDS = Set.new [
    'alias', 'and', 'BEGIN', 'begin', 'break', 'case', 'class', 'def', 'defined', 
    'do', 'else', 'elsif', 'END', 'end', 'ensure', 'false', 'for', 'if', 'in', 
    'module', 'next', 'nil', 'not', 'or', 'redo', 'rescue', 'retry', 'return', 
    'self', 'super', 'then', 'true', 'undef', 'unless', 'until', 'when', 'while', 
    'yield'
  ]

  TOKEN_TYPE = [nil, :comment, :comment, :string, :string, :string, :string, :number, :keyword]
  
  def tokenize script
    RubyTokenizer.tokenize(script)
  end
  
  def self.tokenize script

    script = script.gsub(/\r\n/, " \n") # replace <cr> with a space so that offset is correct
    script = script.gsub(/\r/, "\n")
    
    tokens = []
    
    block_comment_end = /^=end.*/
    
    rxp = Regexp.union(
      /^(=begin)/, 
      /(#.*)\n?/,
      /(<<\w[\w\d]*)$/, 
      /(\".*\")/, 
      /(\'.*\')/, 
      /(\/.*\/)/,
      /(\d+)/, 
      /(:*\w+)/
    )

    offset = 0

    m = rxp.match(script)

    while m

      found = false
      
      m.length.downto(1) do |i|

        if m[i]

          type = TOKEN_TYPE[i]

          if i == 8
            type = :name unless KEYWORDS.include?(m[i])
            type = :symbol if m[i][0] == ?:
          end

          end_pos = m.offset(i)[1]
          
          token = Token.new(offset + m.offset(i)[0], end_pos - m.offset(i)[0], type, m[i])

          if i == 1
            
            end_m = block_comment_end.match(script)
            
            if end_m
              token.length = end_m.offset(0)[1] - m.offset(i)[0]
              end_pos = end_m.offset(0)[1]
            else
              end_pos = script.length - 1
              token.length = end_pos - m.offset(i)[0]
            end
            
          elsif i == 3
            
            document_end = Regexp.new("\n#{token.value[2..-1]}").match(script)
            
            if document_end
              token.length = document_end.offset(0)[1] - m.offset(i)[0]
              end_pos = document_end.offset(0)[1]
            else
              end_pos = script.length - 1
              token.length = end_pos - m.offset(i)[0]
            end
              
          end
          
          tokens << token
          
          found = true
          
          offset = token.offset + token.length

          script = script.slice(end_pos..-1)

          m = rxp.match(script)

          break

        end
        
      end

      break unless found

    end
    
    tokens

  end
  
  def self.dump_tokens script
    
    max_len = 0
    
    text = script.gsub(/\r\n/, ".\n")
    
    text.gsub!(/\r/, "\n")
    
    StringIO.new(text).each do |line|
      max_len = line.length if max_len < line.length
    end
    
    offset = 0
    line_num = 1
    
    StringIO.new(text).each do |line|
      
      l = "#{line_num}"
      
      if l.length < 2
        l = "  " + l
      elsif l.length < 3
        l = " " + l
      end
      
      puts "#{l} #{line}"
      
      print "    "
      offset.upto(offset + max_len) do |i| 
        if i < offset + line.length
          print i % 10 
        else
          print ' '
        end
      end
      puts "  -- len = #{line.length}"
      
      print "    "
      offset.upto(offset + max_len) do |i|
        if i < offset + line.length and i % 10 == 0 and i > 0
          print i / 10
        else
          print ' '
        end
      end
      puts 
      
      print "    "
      offset.upto(offset + max_len) do |i|
        if i < offset + line.length and i % 100 == 0 and i > 0
          print i / 100
        else
          print ' '
        end
      end
      puts 
      
      offset += line.length
      line_num += 1
      
    end
    
    puts "===>"
    puts 
    puts tokenize(script)
    
  end

end

if $0 == __FILE__
  
  debug_mode = false
  
  if ARGV.length > 0
    
    if ARGV[0] == '-debug'
      debug_mode = true
      ARGV.shift
    end
    
  end
  
  ARGV.each do |script_file|
    
    content = File.open(script_file).read
    
    puts "--- #{script_file}:"
    
    if debug_mode
      RubyTokenizer.dump_tokens(content)
    else
      puts RubyTokenizer.tokenize(content)
    end
    
    puts "-------------------"
    
  end
  
end