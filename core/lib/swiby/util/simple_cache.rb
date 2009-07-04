#-- 
#  Copyright (C) Swiby Committers. All rights reserved.
#  
#  The software in this package is published under the terms of the BSD
#  style license a copy of which has been included with this distribution in
#  the LICENSE.txt file.
# 
#++

require 'yaml'
require 'fileutils'
require 'open-uri'
require 'pathname'

module Swiby
  
  #
  # Simple cache manager.
  # 
  # It loads files from a remote site saves them in a local directory 
  # and provides the path where they are located.
  # 
  # The reason why it is named 'simple' is because it does not implement
  # any security, to protect the cache.
  #
  class SimpleCache
    
    #
    # Create an instance.
    #
    # === Args
    #
    # +base_url+::
    #   The base (remote) url as a String.
    # +cache_dir+::
    #   The directory (String) where this cache manager can write cached files
    # +auto_close+::
    #   If +true+ the cache closes automatically when the application shuts 
    #   down (default to +true+).
    #   +WARNING:+ the at_exit technique does not work with jruby
    #
    # === Example
    # 
    #   SimpleCache.new('http://www.my_site.com', ENV['USERPROFILE'])
    #
    def initialize base_url, cache_dir, auto_close = true
      
      @base_url = base_url
      @cache_dir = cache_dir
      
      @base_url += '/' if @base_url[-1] != ?/
      
      @cache_dir += '/' if @cache_dir[-1] != ?/
      @cache_dir.gsub!(/\\/, "/")
      
      match_data = /.*:\/\/(.*)/.match(@base_url)
      
      @cache_dir += match_data[1].gsub!(/:/, "_")
        
      @resolved = {}
      @cache_data = {}
      
      if auto_close
        
        at_exit do
           close
        end
        
      end
      
      reload_cache
      
    end
    
    # Returns the base (remote) URL
    def base_url
      @base_url
    end
    
    #
    # Enables or disables +debug+ mode (if exceptions are raised SimpleCache
    # behaves as beeing offline, if it runs in debug mode it outputs the
    # the exceptions
    # 
    # === Args
    #
    # +enable+::
    #   Enables the debug mode if +enable+ is true
    #
    def debug enable
      @debug_mode = enable
    end
  
    #
    # Returns the local path for the remote +file_path+ or +nil+ if the
    # file does not exist
    #
    # === Args
    #
    # +file_path+::
    #   The file path to retrieve from the cache, fetching it from the
    #   remote site if necessary. It should be a String.
    #
    # === Example
    # 
    #   local_path = cache.from_cache('my_app/controller/index.rb')
    #
    def from_cache file_path
        
      return @resolved[file_path] if @resolved.key?(file_path)
        
      begin
        
        reloaded = true
        
        cache_file = cache_file_name(file_path)
        
        url = @base_url + file_path
        
        entry = FileInfo.new(url)

        open(url) do |remote|
          
          entry.last_modified = remote.last_modified
        
          if @cache_data.key?(file_path) and @cache_data[file_path].last_modified == entry.last_modified
            reloaded = false
          else
          
            File.makedirs File.dirname(cache_file)

            File.open(cache_file, "w") do |file|
              file << remote.read
            end

          end
          
        end

        @cache_data[file_path] = entry if reloaded
        @resolved[file_path] = cache_file
        
      rescue OpenURI::HTTPError => ex
        
        log ex if @debug_mode
        
        return nil if ex.io.status == "404"
        
        resolve_offline file_path
        
      rescue Exception => ex

        if ex.class.to_s == 'Test::Unit::AssertionFailedError'
          raise ex
        end
        
        log ex if @debug_mode
        
        resolve_offline file_path
        
      end
      
    end
    
    # Clears the cache for the current base URL
    def clear
      
      p = Pathname.new(@cache_dir)
    
      p.rmtree if p.exist?

    end
    
    # Closes the cache
    def close
      
      File.makedirs File.dirname(data_file)
      
      File.open(data_file, "w") do |file|
        YAML.dump(@cache_data, file)
      end
      
      @resolved.clear
      
    end
    
    private

    def data_file
      @cache_dir + 'data.yml'
    end
    
    def reload_cache
      
      return unless File.exist?(data_file)
      
      @cache_data = YAML.load_file(data_file)
      
      raise "Bad cache data (#{data_file})" unless @cache_data.instance_of?(Hash)
      
    end

    def resolve_offline file_path
      
      cache_file = cache_file_name(file_path)

      if @cache_data.key?(file_path)
        @resolved[file_path] = cache_file
      else
        nil
      end

    end
    
    def log ex
      puts ex
      print ex.backtrace.join("\n")
    end
    
    def cache_file_name file_path
      
      local_name = file_path

      if local_name =~ /\?/ and not local_name =~ /.*\.rb$/
        local_name = "#{file_path}.rb"
      end

      @cache_dir + local_name.gsub(/\?/, '$')
      
    end
    
  end
  
  class FileInfo
    
    attr_accessor :url, :last_modified
    
    def initialize url
      @url = url
    end
    
  end

end