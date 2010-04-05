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
require 'swiby/mvc/slider'

require 'swiby/layout/grid'
require 'swiby/layout/stacked'

require 'zooming_ui'
require 'slide_button'

require 'yaml'

def icon name
  file = File.expand_path(name, File.expand_path('images', File.dirname(__FILE__)))
  Swiby::create_icon(file)
end

class Product
  
  attr_accessor :name, :description, :last_buy_date
  
  def initialize name, description, last_buy_date
    @name, @description, @last_buy_date = name, description, last_buy_date
  end
  
  def self.load_data file
    @@data_file = file
    @@products = YAML.load_file(file)
  end
  
  def self.save_data
    
    File.open(@@data_file, 'w') do |out|
      YAML.dump(@@products, out) 
    end
    
  end

  def self.products
    @@products
  end
  
end

data_file = File.expand_path('products.yaml', File.dirname(__FILE__))

Product.load_data data_file

f = frame {
  
  title "Shopping Board"
  
  use_styles 'shopping_board_styles.rb'
  
  panel(:layout => :flow, :name => :zoom_container) {
  
    grid(:columns => 6, :name => :products, :hgap => 30, :vgap => 5) {
      # later all the products are displayed here
    }
    
  }
  
  south
    panel(:layout => :flow, :align => :right) {
      image_button icon("zoom_out_normal.png"), icon("zoom_out_hover.png"), :name => :zoom_out
      slider :name => :zoomer, :minimum => 1, :maximum => 50
      image_button icon("zoom_in_normal.png"), icon("zoom_in_hover.png"), :name => :zoom_in
    }
  
  enable_zooming @styles.root.font_size, :zoom_container
      
}

def detail_panel product
  panel(:layout => :stacked, :align => :left, :direction => :vertical) {
    label product.name.to_utf8
    label product.description.to_utf8, :style_class => :detail
    label "Last buy: #{product.last_buy_date.strftime('%m/%d/%Y')}", :style_class => :detail
  }
  slide_button "Buy", ""
end

f.find(:products).content {

  Product.products.each do |product|
    detail_panel product
  end

}

class Ctl
  
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
  
  def on_window_close
    Product.save_data
  end
  
end

puts "-- #{__FILE__} TODOs ---------------------"
puts "| translate"
puts "| print data"
puts "| what about richer components (like zoom command panel) and MVC?"
puts "| improve slide button + include in Swiby?"
puts "| *** improve builder creation methods, they all do the same things"
puts "| Swiby::Builder#zoom_commands_panel initial_level, zoomable_component[Symbol, Component]"
puts "| reset/done - (save, undo)?"
puts "| store last buy date + history of days interval, example: Cheese|Gouda, feta or emental|12/10/2009|[5,7,6,9,3]"
puts "|                                                             => bought on : 12/10, 9/10, 30/9, 24/9, 12/9"
puts "------------------------------------------"

f.visible true

ViewDefinition.bind_controller f, Ctl.new
