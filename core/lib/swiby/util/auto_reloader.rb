#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

#
# The auto-reloader hooks the normal loading (requiring) process of Ruby, so
# that it can reload files at will.
#
# The auto-reloader keeps a list of loaded files, like _require_ would, it reloads files
# only if after clearing the list.
#

require 'swiby/util/remote_loader'

module Kernel

  # alias the orginal require/load
  alias swiby_autoload_sys_require require

  def require file_name
    Swiby::AUTO_RELOADER.process_require file_name
  end

end

module Swiby

  ar = Class.new do

    @@LOAD_CACHE = {}

    def process_require file_name

      return swiby_autoload_sys_require(file_name) if exclude_remote?(file_name)

      return true if @@LOAD_CACHE[file_name]

      begin

        ruby_file_name = file_name
        ruby_file_name += ".rb" unless file_name =~ /\.rb$/ || file_name =~ /\.jar$/
        
        loaded = load(ruby_file_name)

        @@LOAD_CACHE[ruby_file_name] = true if loaded

      rescue LoadError
        loaded = load(file_name)
      end

      @@LOAD_CACHE[file_name] = true if loaded

      loaded

    end

    def clear
      @@LOAD_CACHE.clear
    end

  end

  AUTO_RELOADER = ar.new
  
end