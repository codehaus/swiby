#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/form'

data = [Time.new, 'Simple text', 2]

Defaults.auto_sizing_frame = true

styles = create_styles {
  root(
      :background_color => :white,
      :font_family => Styles::VERDANA,
      :font_style => :normal,
      :font_size => 12
  )
  italic {
    list(
      :color => :blue,
      :font_style => :italic
    )
  }
  bold {
    list(
      :color => :red,
      :font_weight => :bold
    )
  }
  courier {
    list(
      :font_family => Styles::COURIER,
      :font_size => 20,
      :color => :gray
    )
  }
  mix {
    list(
      :font_family => Styles::TIMES_ROMAN,
      :font_size => 16,
      :font_style => :italic,
      :font_weight => :bold,
      :color => :pink
    )
  }
  underline {
    list(
      :color => :orange,
      :text_decoration => :underline
    )
  }
  lignethrough {
    list(
      :text_decoration => 'line-through'
    )
  }
}

Defaults.enhanced_styling = false

frame(:flow) {

  title "Default Swing styling"
  
  width 900
  height 500
  
  use_styles styles
  
  content {
    list ["Default style"] + data, :name => :normal
    list ["Italic blue"] + data, :name => :italic
    list ["Bold red"] + data, :name => :bold
    list ["Courier-20 gray"] + data, :name => :courier
    list ["Times-Roman-16, bold and italic, pink"] + data, :name => :mix
    list ["Not supported underline"] + data, :name => :underline
    list ["Not supported line-through"] + data, :name => :lignethrough
    list("Test change", [1, 2]) {|val|
      unless val.is_a?(Fixnum) and (val == 1 or val == 2)
        raise(RuntimeError, "Expected #{1.class} (1 or 2) but was #{val.class} = #{val}")
      end
    }
  }
  
  visible true
  
}

Defaults.enhanced_styling = true

frame(:flow) {

  title "Enhanced styling"

  width 700
  height 320
  
  use_styles styles

  content {
    list ["Default style"] + data, :name => :normal
    list ["Italic blue"] + data, :name => :italic
    list ["Bold red"] + data, :name => :bold
    list ["Courier-20 gray"] + data, :name => :courier
    list ["Times-Roman-16, bold and italic, pink"] + data, :name => :mix
    list ["Underline orange"] + data, :name => :underline
    list ["Line-through"] + data, :name => :lignethrough
    list("Test change", [1, 2]) {|val|
      unless val.is_a?(Fixnum) and (val == 1 or val == 2)
        raise(RuntimeError, "Expected #{1.class} (1 or 2) but was #{val.class} = #{val}")
      end
    }
  }
  
  visible true
  
}

Defaults.enhanced_styling = false

form {

  title "Reset basic styling"

  width 400
  height 100
  
  use_styles styles

  content {
    list ["No underline should appear here"] + data, :name => :underline
  }
  
  visible true
  
}