#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

def enable_zooming initial_level, component

  instance_variable_set :@zoom_level, initial_level
  instance_variable_set :@zoom_component, component
  
  def self.zoom_level
    @zoom_level
  end
  
  def self.zoom_level= value
    
    @zoom_level = value

    @size_delta = 0 unless @size_delta
    @initial_size = value unless @initial_size

    delta = value - (@initial_size + @size_delta)

    @size_delta += delta
    
    @styles.change!(:font_size) do |path, size|
      size + delta
    end

    find(@zoom_component).apply_styles @styles
    
  end
  
  def self.zoom_in
    self.zoom_level = @zoom_level + 1
  end
  
  def self.zoom_out
    self.zoom_level = @zoom_level - 1
  end
  
end
