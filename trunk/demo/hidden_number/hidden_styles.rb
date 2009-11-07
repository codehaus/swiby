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
    :font_size => 16
  )
  container(
    :background_color => 0xD6CFE6
  )
  label(
    :color => 0x5C458A
  )
  message {
    label(
      :font_size => 17
    )
  }
  numeric_pad {
    button(
      :font_size => 18
    )
  }
  input(
    :color => :black,
    :background_color => 0xAAAAEE
  )
  progress_bar(
    :color => :red
  )
}