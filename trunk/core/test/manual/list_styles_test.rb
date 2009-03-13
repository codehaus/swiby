#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class ListStylesTest < ManualTest

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
  }
  
  manual 'Default Swing styling' do
    
    Defaults.enhanced_styling = false

    frame(:flow) {

      title "Default Swing styling"
      
      width 900
      height 500
      
      use_styles styles
      
      content {
        list ["Default style"] + values, :name => :normal
        list ["Italic blue"] + values, :name => :italic
        list ["Bold red"] + values, :name => :bold
        list ["Courier-20 gray"] + values, :name => :courier
        list ["Times-Roman-16, bold and italic, pink"] + values, :name => :mix
        list ["Not supported underline"] + values, :name => :underline
        list ["Not supported line-through"] + values, :name => :lignethrough
        list("Test change", [1, 2]) {|val|
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

    frame(:flow) {

      title "Enhanced styling"

      width 700
      height 320
      
      use_styles styles

      content {
        list ["Default style"] + values, :name => :normal
        list ["Italic blue"] + values, :name => :italic
        list ["Bold red"] + values, :name => :bold
        list ["Courier-20 gray"] + values, :name => :courier
        list ["Times-Roman-16, bold and italic, pink"] + values, :name => :mix
        list ["Underline orange"] + values, :name => :underline
        list ["Line-through"] + values, :name => :lignethrough
        list("Test change", [1, 2]) {|val|
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
        list ["No underline should appear here"] + values, :name => :underline
      }
      
      visible true
      
    }

  end

end