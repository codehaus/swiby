#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class LabelStylesTest < ManualTest

  styles = create_styles {
    root(
        :background_color => :white,
        :font_family => Styles::VERDANA,
        :font_style => :normal,
        :font_size => 12
    )
    italic {
      label(
        :color => :blue,
        :font_style => :italic
      )
    }
    bold {
      label(
        :color => :red,
        :font_weight => :bold
      )
    }
    courier {
      label(
        :font_family => Styles::COURIER,
        :font_size => 20,
        :color => :gray
      )
    }
    mix {
      label(
        :font_family => Styles::TIMES_ROMAN,
        :font_size => 16,
        :font_style => :italic,
        :font_weight => :bold,
        :color => :pink
      )
    }
    underline {
      label(
        :color => :orange,
        :text_decoration => :underline
      )
    }
    lignethrough {
      label(
        :text_decoration => 'line-through'
      )
    }
    italic_only {
      label(
        :font_style => :italic
      )
    }
    magenta {
      label(
        :color => :magenta
      )
    }
  }

  manual 'Style class' do

    form {

      title "Class styling"

      use_styles styles
      
      content {
        label "Current default style"
        label "Class color: magenta", :style_class => :magenta
        label "Class + id: magenta/italic", :name => :italic_only, :style_class => :magenta
      }
      
      visible true
      
    }
    
  end
  
  manual 'Default Swing styling' do
    
    Defaults.enhanced_styling = false

    form {

      title "Default Swing styling"
      
      use_styles styles
      
      label "Default style label", :normal
      label "Italic blue label", :italic 
      label "Bold red label", :bold
      label "Courier-20 gray label", :courier
      label "Times-Roman-16, bold and italic, pink label", :mix
      label "Not supported underline label", :underline
      label "Not supported line-through label", :lignethrough
      
      visible true
      
    }

  end

  manual 'Enhanced + reset basic styling' do
    
    Defaults.enhanced_styling = true

    form {

      title "Enhanced styling"
      
      use_styles styles
      
      label "Default style label", :normal
      label "Italic blue label", :italic 
      label "Bold red label", :bold
      label "Courier-20 gray label", :courier
      label "Times-Roman-16, bold and italic, pink label", :mix
      label "Underline orange label", :underline
      label "Line-through label", :lignethrough
      
      visible true
      
    }

    Defaults.enhanced_styling = false

    form {

      title "Reset basic styling"
      
      use_styles styles
      
      label "No underline should appear here", :underline
      
      visible true
      
    }

  end
  
end
