#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class TableStylesTest < ManualTest

  styles = create_styles {
    root(
      :background_color => :black
    )
    table(
      :font_family => Styles::TIMES_ROMAN,
      :font_style => :normal,
      :color => :black
    )
    table_header(
      :font_family => Styles::COURIER,
      :font_style => :italic,
      :font_size => 12,
      :color => :blue,
      :background_color => 0x85C0CB
    )
    table_row(
      :font_family => Styles::VERDANA,
      :font_weight => :bold,
      :font_size => 14,
      :color => :yellow,
      :background_color => 0x222299
    )
  }
  
  languages = [
    ['Fortran', 1957], 
    ['Cobol', 1960], 
    ['Basic', 1964],
    ['APL', 1967],
    ['Simula 67', 1967], 
    ['Algol 60', 1969],
    ['PL/I', 1969],
    ['Pascal', 1971],
    ['C', 1972],
    ['Smalltalk', 1972],
    ['Modula-2', 1979],
    ['Ada', 1983],
    ['C++', 1983],
    ['Python', 1991],
    ['Ruby', 1993],
    ['Java', 1995],
    ['Erlang', 1998],
    ['C#', 2000],
  ]
  
  manual 'Default table bg' do
    
    form {

      title 'Root black bg'

      width 300
      height 250

      use_styles styles

      table ['Language', 'Year'], languages

      visible true
    }

  end

  manual 'Set table bg' do
    
    with_blue_styles = styles.merge! {
      table(
        :color => :white,
        :background_color => 0x222299
      )
    }

    form {

      title 'Specific blue bg'

      width 300
      height 250

      use_styles with_blue_styles

      table ['Language', 'Year'], languages

      visible true
    }

  end

end