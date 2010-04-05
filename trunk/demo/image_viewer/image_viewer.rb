#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc/frame'
require 'swiby/mvc/button'
require 'swiby/mvc/image'

import java.awt.Font
import java.awt.Color
import java.awt.BasicStroke
import java.awt.FontMetrics
import java.awt.RenderingHints
import java.awt.image.BufferedImage

import javax.swing.ImageIcon

def create_image id, width
  
  buffer = BufferedImage.new(width, width, BufferedImage::TYPE_INT_ARGB)
      
  g = buffer.createGraphics
		
  if width != 200
    
    scale = width / 200.0
    
    g.scale scale, scale
  
  end
		
  g.setRenderingHint(RenderingHints::KEY_ANTIALIASING, RenderingHints::VALUE_ANTIALIAS_ON)

  g.setColor(Color::BLACK)
  g.setStroke(BasicStroke.new(3))
  g.drawArc(1, 1, 200- 3, 200 - 3, 0, 360)

  text = id.to_s

  g.setFont(Font.new("arial", Font::PLAIN, 123))

  fm = g.getFontMetrics(g.getFont())
  rc = fm.getStringBounds(text, g)

  g.drawString(text, (200 - rc.getWidth) / 2, rc.getHeight.to_i)

  g.dispose()

  ImageIcon.new(buffer)
		
end

photos = []
small_photos = []

if ARGV[0]
  
  unless File.directory?(ARGV[0])
    $stderr.puts "#{ARGV[0]} is not a directory"
    exit
  end

  dir = ARGV[0]

  Dir.new(dir).each do |name|
    
    file = File.expand_path(name, dir)
    
    next unless File.file?(file)
    
    photo = Swiby::create_icon(file)
    
    photos << Swiby.create_thumbnail(photo.image, 400)
    small_photos << Swiby.create_thumbnail(photo.image, 100)
    
  end
  
else
  
  21.times do |i|
    photos << create_image(i, 300)
    small_photos << create_image(i, 100)
  end
  
end

panel = frame {

  title "Image viewer"
  
  use_styles 'viewer_styles.rb'
  
  width 600
  height 600
  
  reflective_panel photos[0], :name => :viewer, :image_width => 400
  
  south
    image_list small_photos, :name => :photos, :gradient_color => Color.new(144,147,155)
    
  def image= image
    self[:viewer].image = image
  end
    
  visible true
  
}

class Controller
  
  def initialize small_photos, photos
    @current_photo = 0
    @small_photos, @photos = small_photos, photos
  end
  
  def photos
    @current_photo
  end
  
  def photos= thumbnail
    @current_photo = @small_photos.index(thumbnail)
    @window.image = @photos[@current_photo]
  end
    
end

ViewDefinition.bind_controller panel, Controller.new(small_photos, photos)
