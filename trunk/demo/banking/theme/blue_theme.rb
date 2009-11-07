#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

# URL scheme
# http://www.wellstyled.com/tools/colorscheme2/index-en.html?mono;26;0;270;0.1;0.9;0.75;0.75;0.5;-0.9;0.5;0.5;0.5;-0.9;0.5;0.5;0.1;0.9;0.75;0.75;0.5;-0.9;0.5;0.5;0.1;0.9;0.75;0.75;0.5;-0.9;0.5;0.5;0.1;0.9;0.75;0.75;0

create_styles {
  root(
    :font_family => Styles::VERDANA,
    :font_style => :normal,
    :font_size => 10
  )
  label(
    :color => 0x5C458A
  )
  input(
    :color => :black,
    :background_color => :white
  )
  button(
    :color => 0x5C458A
  )
  container(
    :background_color => 0xD6CFE6
  )
  border(
    :color => 0x554080
  )
  table_header(
    :font_style => :italic,
    :color => 0x6030BF
  )
  table_row(
    :color => 0x5C458A
  )
}
