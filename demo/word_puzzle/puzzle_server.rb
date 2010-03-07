#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'thread'
require 'mongrel'
require 'cgi/session'

require 'puzzle/grid_factory'

class Collaborator
  
  EVENT_BATCH_SIZE = 10
  
  attr_accessor :other, :grid, :lang
  
  def initialize
    @events = []
    @lock = Mutex.new
  end

  def push_event ev
    @lock.synchronize do
      @events << ev
    end
  end
  
  def dequeue_events
      
    message = ""
    
    @lock.synchronize do
      
      EVENT_BATCH_SIZE.times do
        
        ev = @events.shift
        
        break unless ev
        
        message += "\n" if message.length > 0
        message += ev
        
      end
      
    end
    
    return message if message.length > 0
    
    nil
    
  end
  
  def clear_queue
    
    @lock.synchronize do
        @events.clear
        @events << 'broken'
    end
      
  end
  
  def disconnect
    
    @lock.synchronize do
      
      if @other
        @other.other = nil
        @other.clear_queue
      end
      
      @events.clear
      @other = nil
      
    end
  
  end
  
end

# Enhance Mongrel's wrapper to make it more uniform with the HttpResponse class
class Mongrel::CGIWrapper
    
    def write data
      self.out { data }
    end
    
    def start
      head = {}
      yield head, self
      header(head['Content-Type'])
    end
    
end

class PuzzleBaseHandler < Mongrel::HttpHandler
  
  DEFAULT_TIMEOUT = 120 # 120 sec = 2 minutes
  
  @@available = []
  @@lock_collab = Mutex.new
  @@lock_builder = Mutex.new
  
  def initialize config
    @config = config
  end
  
  def process(request, response)
    
    cgi = Mongrel::CGIWrapper.new(request, response)
    session = CGI::Session.new(cgi, 'database_manager' => CGI::Session::MemoryStore)
    
    process_for_session session, request, cgi
    
  end
  
  def parameters request
    request.body.rewind
    s = request.body.readlines.join
    Mongrel::HttpRequest.query_parse(s)
  end

  def language request, out
    
    params = parameters(request)
    
    lang = params["lang"] 

    lang = 'en' unless lang
    
    unless lang == 'en' or lang == 'fr'
      out.write 'unsupported'
      return nil
    end
    
    lang
      
  end
    
  def heartbeat session
    session[:registered] = Time.now + @config.connection_timeout
  end
  
  def next_available lang
    
    @@lock_collab.synchronize do
    
      index = nil

      i = 0
      
      @@available.each do |collab|

        if collab.lang == lang
          index = i
          break
        end

        i += 1
        
      end

      @@available.delete_at(index) if index
      
    end
    
  end
  
  def add_available collab
    @@lock_collab.synchronize { @@available << collab }
  end
  
  def delete_available collab
    @@lock_collab.synchronize { @@available.delete collab }
  end

  def send text, session, response
    
    heartbeat session
    
    response.start do |head, out|
      
      head["Content-Type"] = "text/plain"
      
      out.write text
      
    end
    
  end
  
  def send_grid request, response
  
    response.start do |head, out|
      
      lang = language(request, out)
      return unless lang
      
      head["Content-Type"] = "text/plain"

      out.write grid_message(lang)
      
    end
    
  end
    
  def grid_message lang

    @@lock_builder.synchronize do

      unless @en_factory
        @en_factory = GridFactory.new
        @fr_factory = GridFactory.new
        @fr_factory.change_language :fr
      end
      
      if lang == 'fr'
        grid = @fr_factory.create
      else
        grid = @en_factory.create
      end
      
      msg = "#{grid.cols};#{grid.rows};"

      grid.each_line do |line|
      
        line.each do |row, col|
          msg += grid[row, col]
        end
      
      end
    
      msg += ';'

      grid.each_word do |word|
        msg += "#{word.text};#{word.reverse?};#{word.slot.join(';')};"
      end
    
      msg
      
    end
    
  end
  
end

class NewPuzzleHandler < PuzzleBaseHandler
  
  def process(request, response)
      
    @config.log_basic "Processing new grid request"
    
    send_grid request, response
  
  end
  
end

class RegisterHandler < PuzzleBaseHandler
    
  def process_for_session session, request, response
      
    @config.log_basic "Processing register request"
    
    response.start do |head, out|
      
      head["Content-Type"] = "text/plain"
      
      if session[:registered] and Time.now > session[:registered]
        delete_available session[:collab]
        session[:registered] = nil
      end
      
      if session[:registered]
        out.write 'love'
      else
        out.write 'welcome'
        session[:collab] = Collaborator.new
        add_available session[:collab]
      end
      
    end
      
    heartbeat session
      
  end
  
end

class UnregisterHandler < PuzzleBaseHandler
  
  def process_for_session session, request, response
      
    @config.log_basic "Processing unregister request"
    
    response.start do |head, out|
      
      head["Content-Type"] = "text/plain"
      
      if session[:registered]
        
        collab = session[:collab]
        collab.disconnect
        
        delete_available collab # in case no collaboration was happening
        
        out.write 'bye'
        session.delete
        
      else
        out.write 'error'
      end
      
    end
      
  end
  
end

class CollaborateHandler < PuzzleBaseHandler
  
  def process_for_session session, request, response
    
    @config.log_detail "Processing collaborate request"
    
    response.start do |head, out|

      head["Content-Type"] = "text/plain"
      
      lang = language(request, out)      
      return unless lang
      
      collab = session[:collab]
      return collab unless collab # the client unregistered while asking for a collaboration...
      
      if collab.other
        out.write collab.other.grid
      else
        
        collab.lang = lang
        
        delete_available collab
        
        other = next_available(lang)
        
        if other
          
          grid = grid_message(lang)
          
          collab.grid = grid
          other.grid = grid
          
          collab.other = other
          other.other = collab
          
          out.write grid
          
        else
          
          add_available collab
          
          out.write 'none'
          
        end

      end
      
    end
    
    heartbeat session
    
  end
  
end

class EventHandler < PuzzleBaseHandler

  def process_for_session session, request, response
    
    @config.log_detail "Processing event request"
      
    other = session[:collab].other
    
    if other
      
      ev = parameters(request)['event']
      other.push_event(ev) if ev and ev.length > 0
      
      @config.log_detail "   event -> #{ev}"
      
      send 'ok', session, response
      
    else
      send 'error', session, response
    end
        
  end
  
end

class ConsumeHandler < PuzzleBaseHandler

  def process_for_session session, request, response
    
    @config.log_detail "Processing consume request"
    
    collab = session[:collab]

    ev = collab.dequeue_events
    
    if ev
      send ev, session, response
    else
      send 'none', session, response
    end
    
  end
  
end

class PuzzleServer

  def initialize timeout = PuzzleBaseHandler::DEFAULT_TIMEOUT, host = '127.0.0.1', port = 3000, log_level = :basic
    @timeout = timeout
    @host = host
    @port = port
    @log_level = log_level
  end
  
  def start silent = false

    port = @port 
    host = @host
    timeout_duration = @timeout
    
    @config = Mongrel::Configurator.new(:host => @host) do

      @timeout_duration = timeout_duration
      
      if silent
        def self.log msg
        end
      end
      
      def self.log_basic msg
        log msg
      end
      
      def self.log_detail msg
        log msg if @log_level == :detail
      end
      
      log "Starting server (#{host}:#{port})"
      
      listener :port => port do
        uri "/puzzle/new", :handler => NewPuzzleHandler.new(self)
        uri "/puzzle/register", :handler => RegisterHandler.new(self)
        uri "/puzzle/unregister", :handler => UnregisterHandler.new(self)
        uri "/puzzle/collaborate", :handler => CollaborateHandler.new(self)
        uri "/puzzle/event", :handler => EventHandler.new(self)
        uri "/puzzle/consume", :handler => ConsumeHandler.new(self)
      end
      
      trap("INT") do
        log "Shutting down..."
        stop
      end
      
      def self.connection_timeout
        @timeout_duration
      end
      
      run
      
    end
    
  end
  
  def stop
    @config.log "Shutting down..."
    @config.stop
  end
  
end

if $0 == __FILE__
  
  require 'optparse'
  
  options = {:host => '127.0.0.1', :port => 3000, :timeout => PuzzleBaseHandler::DEFAULT_TIMEOUT, :log_level => :basic}
  
  parser = OptionParser.new do |opts|
    
    opts.banner = "Usage: #{$0} [options]"
    
    opts.on("-h", "--host name", "HTTP host name/ip for the server") do |h|
      options[:host] = h
    end
    
    opts.on("-p", "--port num", "HTTP port for the server") do |p|
      options[:port] = p.to_i
    end
    
    opts.on("-t", "--timeout duration", "Timeout for client session (in sec)") do |t|
      options[:timeout] = t.to_i
    end
    
    opts.on("-l", "--log level", [:basic, :detail], "Level of logging is basic or detail") do |level|
      options[:log_level] = level
    end
    
  end
  
  parser.parse!
  
  server = PuzzleServer.new(options[:timeout], options[:host], options[:port], options[:log_level])
  server.start.join
  
end
