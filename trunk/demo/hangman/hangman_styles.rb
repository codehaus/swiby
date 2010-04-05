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
    :font_size => 18
  )
  container(
    :background_color => 0xD6CFE6
  )
  label(
    :font_size => 28,
    :color => 0x5C458A
  )
  keys {
    button(
      :background_color => 0xAAAAFF
    )
  }
  valid_letter {
    button(
      :background_color => 0x55DD55
    )
  }
  invalid_letter {
    button(
      :background_color => :black
    )
  }
  number_of_letters {
    label(
      :font_style => :italic,
      :font_size => 38,
      :color => 0xAC454A
    )
  }
  language {
    button(
      :font_size => 10
    )
  }
}