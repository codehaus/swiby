#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

create_styles {

  root(
    :font_family => Styles::VERDANA,
    :font_style => :normal,
    :font_size => 16,
    :color => :red,
    :background_color => :black,
    :display_ticks => false
  )    
  
  detail {
    label(
    :color => :blue,
      :font_size => 0
    )
  }
  
}