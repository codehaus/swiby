#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class ComboStylesTest < ManualTest

  values = [Time.new, 'Simple text', 2]

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
    italic_only {
      list(
        :font_style => :italic
      )
    }
    magenta {
      list(
        :color => :magenta
      )
    }
  }

  manual 'Style class' do

    form {

      title "Class styling"

      use_styles styles
      
      content {
        combo ["Current default style"] + values
        combo ["Class color: magenta"] + values, :style_class => :magenta
        combo ["Class + id: magenta/italic"] + values, :name => :italic_only, :style_class => :magenta
      }
      
      visible true
      
    }
    
  end

  manual 'Default Swing styling' do
    
    Defaults.enhanced_styling = false

    form {

      title "Default Swing styling"

      width 400
      height 260
      
      use_styles styles
      
      content {
        combo ["Default style"] + values, :name => :normal
        combo ["Italic blue"] + values, :name => :italic
        combo ["Bold red"] + values, :name => :bold
        combo ["Courier-20 gray"] + values, :name => :courier
        combo ["Times-Roman-16, bold and italic, pink"] + values, :name => :mix
        combo ["Not supported underline"] + values, :name => :underline
        combo ["Not supported line-through"] + values, :name => :lignethrough
        combo("Test change", [1, 2]) {|val|
          unless val.is_a?(Fixnum) and (val == 1 or val == 2)
            raise(RuntimeError, "Expected #{1.class} (1 or 2) but was #{val.class} = #{val}")
          else
            puts "selected #{val}, correct"
          end
        }
      }
      
      visible true
      
    }

  end
  
  manual 'Enhanced + reset basic styling' do
    
    Defaults.enhanced_styling = true

    form {

      title "Enhanced styling"

      width 400
      height 260
      
      use_styles styles

      content {
        combo ["Default style"] + values, :name => :normal
        combo ["Italic blue"] + values, :name => :italic
        combo ["Bold red"] + values, :name => :bold
        combo ["Courier-20 gray"] + values, :name => :courier
        combo ["Times-Roman-16, bold and italic, pink"] + values, :name => :mix
        combo ["Underline orange"] + values, :name => :underline
        combo ["Line-through"] + values, :name => :lignethrough
        combo("Test change", [1, 2]) {|val|
          unless val.is_a?(Fixnum) and (val == 1 or val == 2)
            raise(RuntimeError, "Expected #{1.class} (1 or 2) but was #{val.class} = #{val}")
          else
            puts "selected #{val}, correct"
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
        combo ["No underline should appear here"] + values, :name => :underline
      }
      
      visible true
      
    }

  end

end
