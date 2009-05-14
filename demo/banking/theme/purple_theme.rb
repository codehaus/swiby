#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

# URL scheme
# http://www.wellstyled.com/tools/colorscheme2/index-en.html?mono;26;0;345;0.1;1;0.5;1;0.25;1;0.5;0.75;0.25;1;0.5;0.75;0.1;1;0.5;1;0.25;1;0.5;0.75;0.1;1;0.5;1;0.25;1;0.5;0.75;0.1;1;0.5;1;0

create_styles {
  root(
    :font_family => Styles::VERDANA,
    :font_style => :normal,
    :font_size => 10
  )
  label(
    :color => 0xBF608A
  )
  input(
    :color => :black,
    :background_color => :white
  )
  button(
    :color => 0xBF608A
  )
  container(
    :background_color => 0xFFE6F1
  )
  border(
    :color => 0xBF608A
  )
  table_header(
    :font_style => :italic,
    :color => 0xFF80B8
  )
  table_row(
    :color => 0xBF608A
  )
}
