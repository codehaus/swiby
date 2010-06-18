#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc/frame'
require 'swiby/mvc/label'
require 'swiby/mvc/button'
require 'swiby/mvc/auto_hide'
require 'swiby/mvc/file_button'
require 'swiby/mvc/check'

require 'swiby/layout/tile'
require 'swiby/layout/stacked'

require '../shopper/zooming_ui'

require 'mp3_metadata'

class ID3Metadata
  
  def attach_checkbox checkbox
    @checkbox = checkbox
  end
  
  def rename?
    @checkbox ? @checkbox.selected? : false
  end
  
end

class Folder
  
  attr_reader :name
  
  def initialize name
    @name = name
  end
  
  def refresh
    
    @files = nil
    
    mp3_files
    
  end
  
  def mp3_files
    
    return @files if @files
    
    @files = []

    Dir["#{@name}/*.{mp3}"].each do |mp3_file|
      @files << ID3Metadata.new(mp3_file)
    end
    
    @files
    
  end
  
end

def icon name
  file = File.expand_path(name, File.expand_path('../shopper/images', File.dirname(__FILE__)))
  Swiby::create_icon(file)
end

def detail_panel mp3
  
  panel(:layout => :stacked, :align => :left, :direction => :vertical) {
  
    file_name = File.basename(mp3.file_name)
    
    if mp3.has_metadata? and mp3.title.length > 0
      title = mp3.track ? "#{mp3.track}. #{mp3.title}" : mp3.title
    else
      
      file_name =~ /(.*)\.mp3$/
      
      title = $1
      
    end
    
    label title.to_utf8
    
    label "<html><font color=black>Album:</font> #{mp3.album}".to_utf8, :style_class => :detail
    label "<html><font color=black>Artist:</font> #{mp3.artist}".to_utf8, :style_class => :detail
    label "<html><font color=black>File:</font> #{file_name}".to_utf8, :style_class => :detail
      
    if mp3.has_metadata?
      cb = check('rename', true)
      mp3.attach_checkbox cb
    else      
      label ' '
    end
    
  }
  
end

f = frame {
  
  title "MP3 files"
  
  width 400
  height 300
  
  use_styles 'styles.rb'
  
  auto_hide('commands', :north, :bg_color => Color::GRAY, :color => Color::BLACK, :layout => :flow, :align => :left, :style_class => :bar) {
    
    open_file("location", :location) { |extensions|
      extensions.add 'MP3 files (*.mp3)', 'mp3'
    }
    
    button "rename", :rename
    button "refresh", :refresh
    
  }
  
  panel(:layout => :border, :name => :zoom_container, :scrollbars => true) {
  
    panel(:layout => :tile, :name => :files, :hgap => 20, :vgap => 15) {
      # later all the files are displayed here
    }
    
  }
  
  south
    panel(:layout => :flow, :align => :right) {
      image_button icon("zoom_out_normal.png"), icon("zoom_out_hover.png"), :name => :zoom_out
      image_button icon("zoom_in_normal.png"), icon("zoom_in_hover.png"), :name => :zoom_in
    }
  
  enable_zooming @styles.root.font_size, :zoom_container
  
  def folder= folder
    
    @folder = folder
    
    title "#{folder.name} - MP3 files"
    
    refresh
    
  end
  
  def refresh
    
    @files.java_component.remove_all
    @folder.refresh
    
    mp3_files = @folder.mp3_files
    
    @files.content {

      mp3_files.each do |mp3|
        detail_panel mp3
      end

    }
      
    @files.apply_styles
  
  end
      
}

class Controller
  
  def zoomer
    @window.zoom_level
  end
  
  def zoomer= value
    adjusting_zoomer value
  end
  
  def adjusting_zoomer value
    @window.zoom_level = value
  end
  
  def zoom_in
    @window.zoom_in
  end
  
  def zoom_out
    @window.zoom_out
  end
  
  def location file
    
    @folder = Folder.new(File.dirname(file))
    
    @window.folder = @folder
    
  end
  
  def may_rename?
    not @folder.nil?
  end
  def rename
    
    to_rename = {}
    
    mp3_files = @folder.mp3_files
    
    mp3_files.each do |mp3|
      
      if mp3.rename?
        
        if to_rename.include?(mp3.title)
          message_box "Renaming leads to conflicts, for instance '#{mp3.title}' appears twice."
          to_rename.clear
          break
        end
        
        to_rename[mp3.title] = mp3
        
      end
      
    end

    to_rename.each do |title, mp3|
      File.rename mp3.file_name, "#{File.dirname(mp3.file_name)}/#{title}.mp3"
    end
    
    refresh
    
  end
  
  def may_refresh?
    not @folder.nil?
  end
  def refresh
    @window.refresh
  end
  
end

f.visible true

ViewDefinition.bind_controller f, Controller.new
