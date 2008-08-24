#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class RadioGroupStylesTest < ManualTest

    data = [Time.new, 2]

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

  manual 'Default Swing styling' do
    
    Defaults.enhanced_styling = false

    form {

      title "Default Swing styling"

      width 400
      height 700
      
      use_styles styles
      
      content {
        radio_group ["Default style"] + data, :name => :normal
        radio_group ["Italic blue"] + data, :name => :italic
        radio_group ["Bold red"] + data, :name => :bold
        radio_group ["Courier-20 gray"] + data, :name => :courier
        radio_group ["Times-Roman-16, bold and italic, pink"] + data, :name => :mix
        radio_group ["Not supported underline"] + data, :name => :underline
        radio_group ["Not supported line-through"] + data, :name => :lignethrough
        radio_group("Test change", [1, 2]) {|val|
          unless val.is_a?(Fixnum) and (val == 1 or val == 2)
            raise(RuntimeError, "Expected #{1.class} (1 or 2) but was #{val.class} = #{val}")
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
      height 700
      
      use_styles styles

      content {
        radio_group ["Default style"] + data, :name => :normal
        radio_group ["Italic blue"] + data, :name => :italic
        radio_group ["Bold red"] + data, :name => :bold
        radio_group ["Courier-20 gray"] + data, :name => :courier
        radio_group ["Times-Roman-16, bold and italic, pink"] + data, :name => :mix
        radio_group ["Underline orange"] + data, :name => :underline
        radio_group ["Line-through"] + data, :name => :lignethrough
        radio_group("Test change", [1, 2]) {|val|
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
        radio_group ["No underline should appear here"] + data, :name => :underline
      }
      
      visible true
      
    }

  end

end