#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby'
require 'swiby/mvc/frame'
require 'swiby/mvc/editor'
require 'swiby/mvc/button'
require 'swiby/mvc/file_button'
require 'swiby/mvc/auto_hide'
require 'swiby/mvc/draw_panel'

require 'swiby/swing/timer'

require 'turtle'

turtle = Turtle.new

f = frame {
  
  width 800
  height 520
  
  title 'Turtle drawing'
  
  panel = draw_panel(:name => :board, &turtle.painter)
  
  layer(:palette) {
    palette(100, 340, true, :name => :editor, :width => 600, :height => 200, :layout => :border) {
      editor :name => :script
    }
  }

  auto_hide('file', :north, :bg_color => Color::YELLOW, :color => Color::BLACK, :layout => :flow, :align => :left) {
    
    open_file("open", :open) { |extensions|
      extensions.add 'Turtle scripts (*.turtle)', 'turtle'
    }
    
    button "save", :save
    
    save_file("save as", :save_as) { |extensions|
      extensions.add 'Turtle scripts (*.turtle)', 'turtle'
    }
    
  }
  
  panel.on_click {
    find(:editor).visible = true
  }
  
  every 1000 do

    if script != @script
      
      turtle.script = script
      
      @script = script
      
      find(:board).repaint
      
    end
    
  end

  def script
    find(:script).text
  end
  
  def script= script
    find(:script).value = script
  end
  
  def script_file= script_file
    title "#{script_file} - Turtle drawing"
  end
  
}

if ARGV[0] == '-lang'
  
  ARGV.shift
  
  raise "missing language after '-lang'" unless ARGV[0]
  
  lang = ARGV.shift

  puts "loading language support for '#{lang}'"
  
  require "lang/#{lang}"
  
end

class TurtleEditorController
  
  attr_accessor :script_file
  
  bindable :script_file
  
  def open script_file
    
    self.script_file = script_file
    
    file = File.new(script_file)
    script = file.read
    
    if script =~ /^#lang:(.*)$/
      
      lang = $1.chomp
      
      puts "loading language support for '#{lang}'"
      
      require "lang/#{lang}"
      
    end
  
    @window.script = script
    @window.script_file = script_file
    
  end
  
  def save
    
    File.open(@script_file, 'w') do |stream|
      stream.puts @window.script
    end
    
  end
  
  def may_save?
    !@script_file.nil?
  end
  
  def save_as script_file
    
    script_file = "#{script_file}.turtle" unless script_file =~ /\.turtle$/
    
    self.script_file = script_file
    
    @window.script_file = script_file
    
    self.save
    
  end
  
end

controller = TurtleEditorController.new

ViewDefinition.bind_controller f, controller

controller.open ARGV[0] if ARGV[0]

f.visible = true

puts "TODO [#{__FILE__}] add gesture ctl-O, ctl-S"
