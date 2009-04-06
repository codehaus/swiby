#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'net/http'
require 'uri'

require 'puzzle/grid'
require 'puzzle/puzzle_builder'

class PuzzleClient
  
  # heartbeat_freq is frequency (number of seconds ) at which this client must
  # send a signal (heartbeat) to the server to keep it registered
  def initialize heartbeat_freq = 30, server_url = 'http://localhost:3000'
    
    @server_url = server_url
    
    if @server_url =~ /\/$/
      @server_url = @server_url[0...-1]
    end
    
    @heartbeat_enabled = false
    
    Thread.new do
      
      loop do
        
        register if @heartbeat_enabled
      
        sleep heartbeat_freq
        
      end
    
    end
    
  end
     
  def new_grid language = :en
    
    unregister if collaborating?
    
    cookies = @cookies
    
    grid = build_grid(post('/puzzle/new', :lang => language))
    
    @cookies = cookies unless @cookies
    
    grid
    
  end
    
  def build_grid text_grid
    PuzzleClient.create_grid(text_grid)
  end
  
  def register
    @heartbeat_enabled = true
    get '/puzzle/register'
  end
    
  def unregister
    @collaborates = false
    @heartbeat_enabled = false
    get '/puzzle/unregister'
  end

  def collaborating?
    @collaborates
  end
  
  def collaborate lang = :en
    response = post('/puzzle/collaborate', :lang => lang.to_s)
    @collaborates = response != 'none'
    response
  end

  def fire_mouse_down row, col
    fire "md;#{row};#{col}"
  end

  def fire_mouse_up row, col
    fire "mu;#{row};#{col}"
  end

  def fire_mouse_move row, col
    fire "mm;#{row};#{col}"
  end

  def fire_found word
    fire "found;#{word}"
  end
  
  def consumer= consumer
    @consumer = consumer
  end
  
  def consume &handler
  
    ev = get('/puzzle/consume')
    
    return if ev == 'none'
    
    if handler.nil?
      handler = @consumer
    else
      handler.instance_eval(&handler)
    end
        
    events = ev.split("\n")
    
    events.each do |ev|
    
      data = ev.split(';')
      
      case data[0]
      when 'mm'
        handler.mouse_move data[1].to_i, data[2].to_i
      when 'md'
        handler.mouse_down data[1].to_i, data[2].to_i
      when 'mu'
        handler.mouse_up data[1].to_i, data[2].to_i
      when 'found'
        handler.word_found data[1]
      when 'broken'
        handler.broken
      end
      
    end
    
  end

  def fire event
    post('/puzzle/event', {'event' => event})
  end
  
  def get path
    
    url = URI.parse(@server_url + path)
    
    req = Net::HTTP::Get.new(url.path)
    
    req['cookie'] = @cookies if @cookies
    
    res = Net::HTTP.start(url.host, url.port) do |http|
      http.request(req)
    end
    
    @cookies = res.response['set-cookie']
    
    res.body
       
   end
  
  def post path, params = nil
    
    url = URI.parse(@server_url + path)
    
    params = {} unless params
    
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data(params)
    req['cookie'] = @cookies if @cookies

    res = Net::HTTP.start(url.host, url.port) do |http|
      http.request(req)
    end
    
    @cookies = res.response['set-cookie']
    
    res.body
       
   end
    

  #
  # string_grid is a string object giving the grid definition
  #
  # The expected format is:
  #   C;R;c1c2c3....;word1;rev1;col11;row11;col12;row12;col13;row13;word2;rev2;col21;row21;...
  #
  #     where 
  #          C and R are the grid's number of columns and rows
  #          c1c2c3... is the squence of all the charcters in the grid (should contain CxR characters)
  #          word{i} is the ith word  to find and must be followed by the reversed flag (true or false) and
  #                       all the cells it uses
  #
  # returns a grid object which contains the #valid? and #error methods (to check if
  # the grid object is valid and the reason that invalidates it
  #
  def self.create_grid string_grid
    GridFactory.new.create(string_grid)
  end

  private

  class GridFactory
    
    def create string_grid
    
      data = string_grid.split(';')
      
      cols = data[0].to_i
      rows = data[1].to_i
      
      if cols <= 0 or rows <= 0
        return invalid_grid("Invalid columns (#{data[0]}) and/or rows (#{data[1]}) value")
      end
      
      data.shift
      data.shift
      
      all = data.shift
      
      if all.length != cols * rows
        return invalid_grid("Number of caracters is wrong, was #{all.length} instead of #{rows * cols}")
      end
      
      @rows = rows
      @cols = cols

      ok, error = fill_solution(data)
      
      return invalid_grid(error) unless ok
      
      fill_cells all
      fill_lines
      
      grid = Grid.new(cols, rows, @lines, @cells, @solution)
      
      class << grid
        
        attr_reader :error
        
        def valid?
          true
        end

      end

      grid
      
    end
    
    private
    
    def invalid_grid error
      
      grid = Grid.new(nil, nil, nil, nil, nil)
      
      class << grid
        
        attr_accessor :error
        
        def valid?
          false
        end

      end

      grid.error = error
      
      grid
      
    end
    
    def fill_solution data
      
      @solution = []
      
      cell = nil
      
      while data.length > 0
        
        word = data.shift
        
        if data.length < word.length * 2
          return [false, "Missing cell location for word (#{word}), has #{data.length} instead of #{word.length * 2}"]
        end

        reversed = data.shift
        
        if reversed != 'true' and reversed != 'false'
          return [false, "Missing 'reversed' flag word (#{word})"]
        end        
        
        reversed = (reversed == 'true')
        
        slot = []
        
        n = word.length * 2
        
        n.times do |i|
          
          x = data.shift
          
          unless x =~ /^[0-9]+$/
            return [false, "Expected number, while parsing word location, but was #{x}"]
          end
          
          n = x.to_i
          
          if n < 0
            return [false, "Invalid negative location (#{x})"]
          end
            
          if i % 2 == 0
            
            if n >= @cols
              return [false, "Column location (=#{n}) greater than max (#{@cols})"]
            end
            
            cell = [n]
            
          else
            
            if n >= @rows
              return [false, "Row location (=#{n}) greater than max (#{@rows})"]
            end
            
            cell << n
            slot << cell
            
          end
          
        end
      
        @solution << Word.new(word, slot, reversed)

      end
      
      return [true, nil]
      
    end
    
    def fill_cells all_chars
      
      @cells = []

      i = 0
      
      @rows.times do |r|

        line = []
        
        @cols.times do |c|
          line << all_chars[i..i]
          i += 1
        end
        
        @cells << line
        
      end
      
    end

    def fill_lines

    @lines = []
    
    @rows.times do |r|
      
      row = []
      
      @cols.times do |c|
        row << [r, c]
      end
      
      @lines << row
      
    end
    
    end
    
  end
  
end
