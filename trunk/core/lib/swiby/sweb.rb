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

require 'swiby/form'
require 'swiby/data'

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

    @container = form(:as_panel)
    @history << @container
    @sources << page
    @history_index += 1
    
    self.open_page(page)

    @top_container.java_component.content_pane.remove 1
    @top_container.java_component.content_pane.add @container.java_component
    @top_container.java_component.validate

  end

  def exit
    # exit the application...
  end

  def back

    return if first_page?

    @history_index -= 1
    @container = @history[@history_index]
    @top_container.title @titles[@history_index]
    @top_container.java_component.content_pane.remove 1
    @top_container.java_component.content_pane.add @container.java_component
    @top_container.java_component.content_pane.validate
    @top_container.java_component.repaint

    self.source = @sources[@history_index]

  end

  def forward

    return if last_page?

    @history_index += 1
    @container = @history[@history_index]
    @top_container.title @titles[@history_index]
    @top_container.java_component.content_pane.remove 1
    @top_container.java_component.content_pane.add @container.java_component
    @top_container.java_component.validate
    @top_container.java_component.repaint

    self.source = @sources[@history_index]

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
  
  def initialize

    browser = self

    @history_index = 0

    @titles = []
    @sources = []
    @history = []

    @base = nil
    @source = $0

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
      end

      toolbar do
        input bind(browser, :source)
      end

    end

    @top_container.java_component.content_pane.add @container.java_component

    @history << @container
    @titles << ""
    @sources << @source

  end
  
  protected
  
  def open_page script_path
    require script_path
  end

end

$context = Sweb.new

def width w
  $context.container.width w if $context.first_page?
end

def height h
  $context.container.height h if $context.first_page?
end

def title t
  $context.register_title t
end

def content &block
  $context.container.instance_eval(&block)
  $context.container.complete
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

          cache_dir = ENV["USERPROFILE"] + "/.swiby/cache/"

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
