#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'pwr_remoting'

require 'swiby'

require "swiby/util/simple_cache"
require "swiby/util/remote_require"

# class_name can be a string or a symbol
def remoting_class class_name
  Swiby::RemoteLoader.cache_manager.download_class class_name
end

class PWRCache
  
  def initialize base_url, remote_service, cache_dir, auto_close = true
    @real_cache = SimpleCache.new(base_url, cache_dir, auto_close)
  end
  
  def base_url
    @real_cache.base_url
  end
  
  def debug enable
    @real_cache.debug enable
  end
  
  def from_cache file_path
    @real_cache.from_cache file_path
  end
  
  def clear
    @real_cache.clear
  end
  
  def close
    @real_cache.close
  end
    
  # new method / no delegate
  def download_class class_name
    file = from_cache "ruby/classdefs?#{class_name}"
    file = class_name unless file
    sys_require file
  end

end

require 'swiby/util/arguments_parser'

parser = create_parser_for('sweb_for_pwr', '1.0') {
  
  accept optional, :service_path, '-s', '--service service_path', "Path of the email service relative to script's\nserver (should send ruby format).\nDefaults to script's path with ruby."
  accept required, :script_url, :doc => 'Script URL to run'
  accept_remaining optional, :script_args, "Arguments for the script.\nReplaces the ARGV values when the script is run."
  
  validator do |options|
    
    reject "Invalid URL for script: #{options.script_url}" unless options.script_url =~ /^http[s]?:\/\//
    
    options.script_url =~ /^(.*?\/\/)*([\w\.\d\-]*)(:(\d+))*(\/*)(.*)$/

    options.host = "#{$2}"
    options.port = $4
    options.port = '80' unless options.port
    
    script = "#{$6}"
    script =~ /(.*)\/([^\/]*)/
    
    options.script = $2 ? "#{$2}" : script
    options.base_url = "http://#{options.host}:#{options.port}/#{$1}"
    
    options.service = "/#{$1}/ruby"
    
    if options.service_path
      
      if options.service_path =~ /^\//
        options.service = options.service_path
      else
        options.service = "/#{options.service_path}"
      end
      
    end
    
    options
    
  end
  
}
  
options = parser.parse(ARGV)

puts "Running script: #{options.script_url}"

base = options.base_url
script = options.script

## from sweb / small change => cache_manager wrapped in PWRCache
cache_dir = System::get_property('user.home') + "/.swiby/cache/"

Swiby::RemoteLoader.cache_manager = PWRCache.new(base, 'ruby', cache_dir)

$:.unshift cache_dir

puts "Starting remote, base is #{base}, script is #{script}" #TODO write in a log file?

#require script
## from wseb

remoting_class 'Auth'
remoting_class 'Sent'
remoting_class 'Mailbox'
remoting_class 'Inbox'

require script

Views[:login_view].instantiate(LoginController.new(create_connection(options)))

