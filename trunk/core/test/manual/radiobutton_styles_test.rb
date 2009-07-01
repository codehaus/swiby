#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout/stacked'
require 'swiby/component/radio_button'

class RadioButtonStylesTest < ManualTest

  styles = create_styles {
    root(
        :background_color => :white,
        :font_family => Styles::VERDANA,
        :font_style => :normal,
        :font_size => 12
    )
    italic {
      button(
        :color => :blue,
        :font_style => :italic
      )
    }
    bold {
      button(
        :color => :red,
        :font_weight => :bold
      )
    }
    courier {
      button(
        :font_family => Styles::COURIER,
        :font_size => 20,
        :color => :gray
      )
    }
    mix {
      button(
        :font_family => Styles::TIMES_ROMAN,
        :font_size => 16,
        :font_style => :italic,
        :font_weight => :bold,
        :color => :pink
      )
    }
    underline {
      button(
        :color => :orange,
        :text_decoration => :underline
      )
    }
    lignethrough {
      button(
        :text_decoration => 'line-through'
      )
    }
    italic_only {
      button(
        :font_style => :italic
      )
    }
    magenta {
      button(
        :color => :magenta
      )
    }
  }

  manual 'Style class' do

    frame(:layout => :stacked, :vgap => 5) {

      title "Class styling"

      use_styles styles
      
      content {
        radio "Current default style"
        radio "Class color: magenta", :style_class => :magenta
        radio "Class + id: magenta/italic", :italic_only, :style_class => :magenta
      }
      
      visible true
      
    }
    
  end

  manual 'Default Swing styling' do
    
    Defaults.enhanced_styling = false

    frame(:layout => :stacked, :vgap => 5) {

      title "Default Swing styling"
      
      use_styles styles
      
      content {
        radio "Default style radio", :normal
        radio "Italic blue radio", :italic 
        radio "Bold red radio", :bold
        radio "Courier-20 gray radio", :courier
        radio "Times-Roman-16, bold and italic, pink radio", :mix
        radio "Not supported underline radio", :underline
        radio "Not supported line-through radio", :lignethrough
      }
      
      visible true
      
    }

  end
  
  manual 'Enhanced + reset basic styling' do
    
    Defaults.enhanced_styling = true

    frame(:layout => :stacked, :vgap => 5) {

      title "Enhanced styling"
      
      use_styles styles

      content {
        radio "Default style radio", :normal
        radio "Italic blue radio", :italic 
        radio "Bold red radio", :bold
        radio "Courier-20 gray radio", :courier
        radio "Times-Roman-16, bold and italic, pink radio", :mix
        radio "Underline orange radio", :underline
        radio "Line-through radio", :lignethrough
      }
      
      visible true
      
    }

    Defaults.enhanced_styling = false

    frame(:layout => :stacked, :vgap => 5) {

      title "Reset basic styling"
      
      use_styles styles

      content {
        radio "No underline should appear here", :underline
      }
      
      visible true
      
    }

  end
  
end
