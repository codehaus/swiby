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
    :color => 0x440547
  )
  list_view {
    list(
      :color => 0x440547,
      :background_color => 0xf5671a,
      :border_color => 0x440547,
      :margin => 10,
      :padding => 10,
      :font_size => 10
    )
  }
  list(
    :color => 0x440547,
    :font_size => 14,
    :font_family => "Comic Sans MS",
    :background_color => 0xf5671a
  )
  button(
    :color => 0x440547,
    :font_size => 16
  )
  container(
    :background_color => 0xf5671a
  )
  table(
    :margin => 10,
    :background_image => 'images/balloon.jpg',
    :found_color => :white,
    :collab_color => :yellow
  )
  table_row(
    :font_style => :italic,
    :border_color => 0xfafbbc
  )
  connect {
    button(
      :font_size => 10
    )
  }
}
