#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

# To use JSON format, need to install some gem:
#         gem install json-jruby
#         or jruby -S gem install json-jruby

#either use
#     require 'rubygems'
# either set env variable
#     set JRUBY_OPTS=-rubygems
require 'rubygems'
require 'erb'
require 'net/http'

class JSONParser
  
  attr_accessor :last_error
  
  def parse data
    symbolize!(JSON.parse(data))
  end
  
  def parse? data
    
    @last_error = nil
    
    @last_error = symbolize!(JSON.parse(data)) unless data.chomp == "\"OK\""
    
    @last_error.nil?
    
  end
  
  def last_error
    @last_error
  end
  
  private
  
  # change keys names in hash maps (JSON objects) from String type to Ruby symbols (more rubish)
  def symbolize! data
    
    data.each {|el| symbolize!(el)} if data.is_a?(Array)
    
    if data.is_a?(Hash)
      
      h = data.to_a
      data.clear
      
      h.each do |pair|
        data[pair[0].to_sym] = symbolize!(pair[1])
      end
    
    end
  
    data
    
  end
  
end

class RubyParser
  
  attr_accessor :last_error
  
  def parse data
    eval(data)
  end
  
  def parse? data
    
    @last_error = nil
    
    data = eval(data)
    
    @last_error = data unless data == "OK"
    
    @last_error.nil?
    
  end
  
  def last_error
    @last_error
  end
  
end

class Connection
  
  def initialize server, port, service_path, parser
    @http = Net::HTTP.new(server, port)
    @service_path = service_path
    @headers = nil
    @parser = parser
  end

  def submit remote_class, method, args = {}
    @parser.parse(post(remote_class, method, args))
  end
  
  def submit? remote_class, method, args = {}
    @parser.parse?(post(remote_class, method, args))
  end
  
  def last_error
    @parser.last_error
  end
  
  def last_error= last_error
    @parser.last_error = last_error
  end
  
  private
  
  def post remote_class, method, args
    
    path = "#{@service_path}/#{remote_class}/#{method}"
    
    body = args.map {|k,v| "#{k}=#{ERB::Util.url_encode(v)}"}.join("&")
    
    resp, data = @http.start { |http| http.post(path, body, @headers) }
    
    unless resp.kind_of?(Net::HTTPSuccess)
      raise "URI '#{path}' not found" if resp.is_a?(Net::HTTPNotFound)
      raise "Request error '#{resp.message}' for '#{path}'"
    end
    
    @headers = { 'Cookie' => resp.response['set-cookie']} if resp.response['set-cookie']
    
    data
    
  end
  
end

def parse_remoting_options args, app_name = __FILE__, version = '1.0'

  require 'swiby/util/arguments_parser'

  parser = create_parser_for(app_name, version) {
    
    accept optional, :port, '-p', '--port port_number', 'Server port (defaults to 80)'
    accept required, :host, '-h', '--host host_name', 'Server host name'
    accept required, :service, '-s', '--service service_path', 'Path for email service'
    accept optional, :use_json, '-j', '--json', :doc => "Use JSON instead of Ruby data transfer\n(default to Ruby)"
    
    validator do |options|
      options.port = 80 unless options.port
    end
    
  }
  
  options = parser.parse(args)

  require 'json' if options.use_json

  options
  
end

def create_connection options
  
  parser = options.use_json ? JSONParser.new : RubyParser.new
  
  puts "Connection to #{options.host}:#{options.port}#{options.service}"
  puts "Using JSON data format" if options.use_json
  
  Connection.new(options.host, options.port, options.service, parser)
  
end
