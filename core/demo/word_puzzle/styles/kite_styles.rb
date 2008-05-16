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
    :font_size => 10
  )
  label(
    :color => 0x5C458A
  )
  list_view {
    list(
      :color => 0x5C458A,
      :background_color => 0xD6CFE6,
      :border_color => 0x554080,
      :margin => 10,
      :padding => 10,
      :font_size => 10
    )
  }
  list(
    :color => 0x5C458A,
    :font_size => 14,
    :font_family => "Comic Sans MS",
    :background_color => 0xD6CFE6
  )
  button(
    :color => 0x5C458A,
    :font_size => 16
  )
  container(
    :background_color => 0xD6CFE6
  )
  table(
    :margin => 10,
    :background_image => 'images/kite.jpg'
  )
  table_row(
    :font_style => :italic,
    :border_color => 0x554080
  )
}
