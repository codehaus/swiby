#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout/stacked'

class CheckboxStylesTest < ManualTest

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

      title "Default Swing styling"

      use_styles styles
      
      content {
        check "Current default style"
        check "Class color: magenta", :style_class => :magenta
        check "Class + id: magenta/italic", :italic_only, :style_class => :magenta
      }
      
      visible true
      
    }
    
  end

  manual 'Default Swing styling' do

    Defaults.enhanced_styling = false

    frame(:layout => :stacked, :vgap => 5) {

      title "Class styling"
      
      use_styles styles
      
      content {
        check "Default style check", :normal
        check "Italic blue check", :italic 
        check "Bold red check", :bold
        check "Courier-20 gray check", :courier
        check "Times-Roman-16, bold and italic, pink check", :mix
        check "Not supported underline check", :underline
        check "Not supported line-through check", :lignethrough
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
        check "Default style check", :normal
        check "Italic blue check", :italic 
        check "Bold red check", :bold
        check "Courier-20 gray check", :courier
        check "Times-Roman-16, bold and italic, pink check", :mix
        check "Underline orange check", :underline
        check "Line-through check", :lignethrough
      }
      
      visible true
      
    }

    Defaults.enhanced_styling = false

    frame(:layout => :stacked, :vgap => 5) {

      title "Reset basic styling"
      
      use_styles styles

      content {
        check "No underline should appear here", :underline
      }
      
      visible true
      
    }
    
  end
  
end
