#-- 
#  Copyright (C) Swiby Committers. All rights reserved.
#  
#  The software in this package is published under the terms of the BSD
#  style license a copy of which has been included with this distribution in
#  the LICENSE.txt file.
# 
#++
  
require 'set'

module Kernel

  def resolve_file file_name

    #puts "resolve_file #{file_name}" #TODO in 'debug' mode should log this...
    
    Swiby::RemoteLoader.from_cache(file_name)

  end
  
end

module Swiby
  
  class RemoteLoader
    
    def self.from_cache file_name
      @@cache_manager.from_cache(file_name) if @@cache_manager
    end
    
    def self.cache_manager
      @@cache_manager
    end
    
    def self.cache_manager= cache_manager
      @@cache_manager = cache_manager
    end
    
    @@cache_manager = nil
    
  end
  
  
  def script? name
    
    return false if name.length < 4
    
    ext = name[-3..-1].downcase
    return true if ext == '.rb'
    
    false
    
  end
  
  def exclude_remote? name
    
    return true if EXCLUDE_REMOTE.include?(name)
    
    return true if name =~ Regexp.new("swiby/")
    return true if name =~ Regexp.new("test/unit/")
    
    false
    
  end
  
  EXCLUDE_REMOTE = Set.new([
      'net/http', 'net/ftp', 'net/protocol.rb', 'net/pop.rb', 'net/https.rb', 'uri', 
      'set',
      'time',
      'test/unit',
      'find',
      'pathname',
      'yaml'])
  
end
