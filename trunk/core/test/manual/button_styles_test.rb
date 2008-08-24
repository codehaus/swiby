#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class ButtonStylesTest < ManualTest
  
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
  }

  manual 'Default Swing styling' do

    Defaults.enhanced_styling = false

    frame(:layout => :stacked, :vgap => 5) {

      title "Default Swing styling"

      use_styles styles
      
      content {
        button "Default style button", :normal
        button "Italic blue button", :italic 
        button "Bold red button", :bold
        button "Courier-20 gray button", :courier
        button "Times-Roman-16, bold and italic, pink button", :mix
        button "Not supported underline button", :underline
        button "Not supported line-through button", :lignethrough
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
        button "Default style button", :normal
        button "Italic blue button", :italic 
        button "Bold red button", :bold
        button "Courier-20 gray button", :courier
        button "Times-Roman-16, bold and italic, pink button", :mix
        button "Underline orange button", :underline
        button "Line-through button", :lignethrough
      }
      
      visible true
      
    }

    Defaults.enhanced_styling = false

    frame(:layout => :stacked, :vgap => 5) {

      title "Reset basic styling"
      
      use_styles styles

      content {
        button "No underline should appear here", :underline
      }
      
      visible true
      
    }
    
  end
    
end
