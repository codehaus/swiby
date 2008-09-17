#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'ostruct'
require 'net/http'
require 'uri'

require 'swiby/form'
require 'swiby/data'
require 'swiby/tools/console'

def image_path image
  File.join(File.dirname(__FILE__), 'images', image)
end

class Sweb

  attr_accessor :source
  attr_reader :container, :top_container

  def start
    @top_container.visible = true
  end

  def goto page

    @history_index += 1
    
    while @history.length > @history_index
      @history.pop
      @sources.pop
      @titles.pop
    end
    
    @container = form(:as_panel)
    @history << @container
    @sources << page
    @titles << ''
    
    self.open_page(page)

    @top_container.default_layer.remove 1
    @top_container.default_layer.add @container.java_component
    @top_container.java_component.validate

    @console.run_context = @container if @console
    
  end

  def exit
    # exit the application...
  end

  def back

    return if first_page?

    @history_index -= 1
    @container = @history[@history_index]
    @top_container.title @titles[@history_index]
    @top_container.default_layer.remove 1
    @top_container.default_layer.add @container.java_component
    @top_container.default_layer.validate
    @top_container.java_component.repaint

    self.source = @sources[@history_index]

    @console.run_context = @container if @console
    
  end

  def forward

    return if last_page?

    @history_index += 1
    @container = @history[@history_index]
    @top_container.title @titles[@history_index]
    @top_container.default_layer.remove 1
    @top_container.default_layer.add @container.java_component
    @top_container.java_component.validate
    @top_container.java_component.repaint

    self.source = @sources[@history_index]

    @console.run_context = @container if @console
    
  end

  def has_history?
    @history.size > 1
  end
  
  def first_page?
    @history_index == 0
  end

  def last_page?
    @history_index + 1 >= @history.size
  end

  def register_title t
    @top_container.title t
    @titles[@history_index] = t
  end
  
  def apply_styles styles
    @container.apply_styles styles
  end
  
  def java_component
    @top_container.java_component
  end
  
  def session
    @session = OpenStruct.new unless @session
    @session
  end
  
  def initialize

    browser = self

    @history_index = 0

    @titles = []
    @sources = []
    @history = []

    if $0 == __FILE__ or $0 == '-e' # $0 = -e if run from installed gem/bin command
      @source = ARGV[0]
    else
      @source = $0
    end

    @container = form(:as_panel)
    
    @top_container = frame do

      toolbar do
        button do
          icon image_path("go-previous.png")
          enabled bind(browser, :source) {|context| not context.first_page?}
          action proc {$context.back}
        end
        button create_icon(image_path("go-next.png")), :more_options do
          enabled bind(browser, :source) {|context| not context.last_page?}
          action proc {$context.forward}
        end
        separator
        button create_icon(image_path("console.png")) do
          $context.show_console
        end
      end

      toolbar do
        input bind(browser, :source)
      end

    end

    @top_container.default_layer.add @container.java_component

    @history << @container
    @titles << ""
    @sources << @source

  end
  
  def show_console

    unless @console
      @console = open_console(@container, @top_container)
    end

    @console.visible = true if not @console.visible?

  end
  
  protected
  
  def open_page script_path
    load script_path
    self.source = script_path
  end

end

$context = Sweb.new

def width w
  $context.top_container.width w if $context.first_page? and !$context.has_history?
end

def height h
  $context.top_container.height h if $context.first_page? and !$context.has_history?
end

def title t
  $context.register_title t
end

def content *layout, &block
  $context.container.content(*layout, &block)
end

module Swiby
  
  module Sweb
    
    def self.run

      if ARGV.length == 0

        $context.source = ""

        $context.top_container.width 600
        $context.top_container.height 400

        $context.start

      else

        if ARGV[0] =~ /http\:\/\/.*|https\:\/\/.*/

          require "swiby/util/simple_cache"
          require "swiby/util/remote_require"

          match_data = /(.*)\/(.*)/.match(ARGV[0])

          base = match_data[1]
          script = match_data[2]

          cache_dir = System::get_property('user.home') + "/.swiby/cache/"

          Swiby::RemoteLoader.cache_manager = Swiby::SimpleCache.new base, cache_dir

          $:.unshift cache_dir

          puts "Starting remote, base is #{base}, script is #{script}" #TODO write in a log file?

          require script

        else

          $:.unshift File.dirname(File.expand_path(ARGV[0]))

          require "swiby/util/remote_loader"

          # replace resolve_file defined in remote_loader
          eval %{
            module ::Kernel

              def resolve_file file_name

                return $:[0] + '/' + file_name if not File.exist?(file_name)

              end

            end
          }

          require ARGV[0]

        end

      end
      
    end
    
  end
  
end

if $0 == __FILE__
  Swiby::Sweb::run
end
