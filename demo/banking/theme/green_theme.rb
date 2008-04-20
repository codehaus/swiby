#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

# URL scheme
# http://www.wellstyled.com/tools/colorscheme2/index-en.html?mono;26;0;135;0.5;-0.9;0.5;0.5;0.1;0.9;0.75;0.75;0.5;-0.9;0.5;0.5;0.1;0.9;0.75;0.75;0.5;-0.9;0.5;0.5;0.1;0.9;0.75;0.75;0.5;-0.9;0.5;0.5;0.1;0.9;0.75;0.75;0

create_styles {
  root(
    :font_family => Styles::VERDANA,
    :font_style => :normal,
    :font_size => 10
  )
  label(
    :color => 0x738040
  )
  input(
    :color => :black,
    :background_color => :white
  )
  button(
    :color => 0x738040
  )
  container(
    :background_color => 0xE1E6CF
  )
  border(
    :color => 0x738040
  )
  table_header(
    :font_style => :italic,
    :color => 0xA3BF30
  )
  table_row(
    :color => 0x738040
  )
}
