#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/styles'

require 'swiby/mvc/frame'
require 'swiby/mvc/label'
require 'swiby/mvc/button'
require 'swiby/mvc/slider'

require 'swiby/mvc/image'
require 'swiby/mvc/draw_panel'

require 'swiby/layout/card'
require 'swiby/layout/page'

require 'swiby/swing/timer'

require 'smiley'

import org.codehaus.swiby.util.ArrowButton

def icon name
  file = File.expand_path(name, File.expand_path('images', File.dirname(__FILE__)))
  Swiby::create_icon(file)
end

if ARGV[0]
  file = File.new(ARGV[0])
  script = file.read
  sequencer = eval(script)
else
  sequencer = smiley {
    is happy
    winks left_eye
  }
end

to_edit = ArrowButton.create(ArrowButton::Orientation::WEST, 20)
to_player = ArrowButton.create(ArrowButton::Orientation::EAST, 20)

f = frame(:layout => :card, :effect => :slide) {
  
  width 800
  height 520
  
  title 'Animation'
  
  use_styles {
    root(
      :background_color => :black,
      :display_ticks => false,
      :color => :white
    )
    label(
      :font_family => Styles::COURIER,
      :font_weight => :bold,
      :color => :green,
      :font_size => 18
    )
  }
  
  card(:player, :layout => :page) {
    body :center
      draw_panel(:name => :board, :width => 320, :height => 320, &sequencer.painter)

    footer :right
      image_button(to_edit[0], to_edit[1]) {
        f.layers[:palette].find(:controller).visible = false
        context.show_card :editor
      }
  }
  
  card(:editor, :layout => :page) {
  
    body :expand
      film_list sequencer.image_frames(120, 120), :name => :frames, :item_layout => :tile
    
    footer :right
      image_button(to_player[0], to_player[1]) {
        f.layers[:palette].find(:controller).visible = true
        context.show_card :player
      }
      
  }

  layer(:palette) {
    palette(120, 360, false, :name => :controller) {
      image_button icon("stop.png"), icon("stop_hi.png"), :name => :stop
      image_button icon("play.png"), icon("play_hi.png"), :name => :play
      image_button icon("pause.png"), icon("pause_hi.png"), :name => :pause
      image_button icon("back.png"), icon("back_hi.png"), :name => :back
      image_button icon("forward.png"), icon("forward_hi.png"), :name => :forward
      slider :minimum => 0, :maximum => sequencer.size, :name => :playback_position
      label "", :name => :time
    }
  }
  
  def repaint
    
    @board = find(:board) unless @board      
    @board.layer(:smiley).repaint
    
  end
  
  def number_of_frames n
    layers[:palette].find(:playback_position).java_component.maximum = n
  end
  
}

class Controller

  bindable :position
  attr_accessor :position, :playback_position
  
  def initialize sequencer
    @time = 0 
    @frame_index = 0
    @sequencer = sequencer
    sequencer.position_listener = self
  end
  
  def play
    @sequencer.start
  end
  def show_play?
    !@sequencer.playing?
  end
  
  def pause
    @sequencer.pause
  end
  def show_pause?
    @sequencer.playing?
  end
  
  def stop
    @time = 0
    @sequencer.stop    
  end
  
  def back
    @sequencer.backward
  end
  
  def forward
    @sequencer.forward
  end
  
  def remove_frames index
    @time = 0
    @sequencer.delete_at index
    @window.number_of_frames @sequencer.size
  end
  
  def show_frames?
    !@sequencer.playing?
  end
  
  def position= p
    
    @position = p
  
    self.playback_position = p
    
    if @sequencer
      @time += 40 if @sequencer.playing?
      @sequencer.goto p unless @sequencer.playing?
      @window.repaint
    end
  
  end
    
  def time
    "%02d:%02d:%02d" % [(@time / 1000) / 60, (@time / 1000).modulo(60), @time.modulo(1000) / 10]
  end
  
end

controller = Controller.new(sequencer)

ViewDefinition.bind_controller f, controller
  
f.visible = true
