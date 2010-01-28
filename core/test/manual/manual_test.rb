#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class TestSuite
  
  def initialize name
    @name = name
    @all_tests = []
  end
  
  def << test
    @all_tests << test
  end
  
  def each
    
    @all_tests.each do |test|
      yield test
    end
    
  end
  
  def count
    @all_tests.size
  end
  
  def succeeded
    @all_tests.inject(0) { |sum, test| sum + (test.succeeded? ? 1 : 0)  }
  end
  
  def executed
    @all_tests.inject(0) { |sum, test| sum + (test.executed? ? 1 : 0)  }
  end
  
  def humanize
    
    cname = @name
    cname = cname[0..-5] if cname =~ /.*Test/
    
    name = ''
    last_char = ''
    last_was_uppercase = false
    
    cname.length.times do |i|
      
      char = cname[i..i]
      
      if char =~ /[A-Z]/
        
        name += last_char
        name += ' ' if name.length > 0 and !last_was_uppercase
        
        last_was_uppercase = true
        
      else
        
        last_char.downcase! if name.length > 0
        
        name += ' ' if name.length > 0 and last_was_uppercase
        name += last_char
        
        last_was_uppercase = false
        
      end
      
      last_char = char
      
    end
    
    name + last_char
    
  end
  
end

class ManualTest
  
  @@all_suites = {}

  def self.suites
    
    sets = []
    
    @@all_suites.each_value do |set|
      sets << set
    end
    
    sets
    
  end
  
  def self.manual desc, &block
    
    name = self.name
    
    @@all_suites[name] = TestSuite.new(name) unless @@all_suites[name]
    @@all_suites[name] << self.new(desc, &block)
    
  end

  def initialize desc, &block
    @desc = desc
    @block = block
    @executed = false
    @succeeded = false
  end
  
  def setup
  end
  
  def tear_down
  end
  
  def description
    @desc
  end
  
  def execute
    
    @executed = true
    @succeeded = false
    
    setup
    @block.call
    tear_down
    
  end
  
  def executed?
    @executed
  end
  
  def succeeded?
    @succeeded
  end
  
  def succeeded= yes
    @succeeded = yes
  end
  
end
