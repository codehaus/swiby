#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

# URL scheme
# http://www.wellstyled.com/tools/colorscheme2/index-en.html?mono;50;0;105;0.25;1;0.5;1;-1;-1;1;-0.7;-1;-1;1;-0.7;0.25;1;0.5;1;-1;-1;1;-0.7;0.25;1;0.5;1;-1;-1;1;-0.7;0.25;1;0.5;1;0

create_styles {
  root(
    :font_family => Styles::VERDANA,
    :font_style => :normal,
    :font_size => 10
  )
  label(
    :color => 0xB3A000
  )
  input(
    :color => :black,
    :background_color => :white
  )
  button(
    :color => 0xB3A000
  )
  container(
    :background_color => 0xFFF280
  )
  border(
    :color => 0xB3A000
  )
  table_header(
    :font_style => :italic,
    :color => 0xB3A000
  )
  table_row(
    :color => 0xB3A000
  )
}
