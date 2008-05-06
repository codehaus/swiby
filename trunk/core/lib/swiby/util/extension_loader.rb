#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Kernel

  def require_extension category, extension, version = nil
    
    return if Swiby::Extension.loaded?(category, extension, version)
      
    raise(LoadError, "Extension not found -- #{extension}") unless $SWIBY_EXT_PATHS
    
    category = category.to_s

    if extension =~ /[.]rb$/
      file = File.join(category, extension)
    else
      file = File.join(category, extension + '.rb')
    end
    
    $SWIBY_EXT_PATHS.each do |dirname|

      next unless File.exist?(dirname)

      ext = File.expand_path(file, dirname)

      if File.exist?(ext)
        require ext
        return
      end

    end
    
    raise(LoadError, "Extension not found -- #{extension}")
      
  end
  
end

module Swiby
  
  class Extension
    
    def self.load_extensions_for category

      return unless $SWIBY_EXT_PATHS

      category = category.to_s

      $SWIBY_EXT_PATHS.each do |dirname|

        dirname = File.expand_path(category, dirname)

        next unless File.exist?(dirname)

        Dir.open(dirname).each do |ext|
          next unless ext =~ /[.]rb$/
          require "#{dirname}/#{ext}"
          close_registration
        end

      end

    end
  
    def self.loaded? category, name, version = nil
      @@extensions.has_key?([category, name, version])
    end
    
    def self.inherited subclass
      @@unregistered << subclass      
    end
    
    def self.each
      
      @@extensions.each_value do |ext|
        yield ext
      end
      
    end

    def self.name
      self.to_s
    end

    def self.category
      self::CATEGORY
    end

    def self.version
      self::VERSION
    end
    
    def self.author
      self::AUTHOR
    end
    
    @@extensions = {}
    @@unregistered = []
    
    private
    
    def self.close_registration
      
      unregistered = @@unregistered
      
      @@unregistered = []
      
      unregistered.each do |ext|
      
        key = [ext.category, ext.name, ext.version]

        @@extensions[key] = ext
        
      end
      
    end
    
  end
  
end