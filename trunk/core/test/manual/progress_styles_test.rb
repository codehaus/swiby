#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/progress_bar'

class ProgressBarStylesTest < ManualTest

  styles = create_styles {
    root(
        :font_family => Styles::VERDANA,
        :font_style => :normal,
        :font_size => 16
    )
    bold {
      progress_bar(
        :color => :red,
        :font_weight => :bold
      )
    }
    courier {
      progress_bar(
        :font_family => Styles::COURIER,
        :font_size => 20,
        :color => :gray
      )
    }
    italic_only {
      progress_bar(
        :font_style => :italic
      )
    }
    magenta {
      progress_bar(
        :color => :magenta
      )
    }
  }

  manual 'All styles options' do

    form {

      title "All styles options"

      use_styles styles
      
      content {
        label 'No style (no text)'
        progress
        
        label 'Verdana 16 (default)'
        progress
            swing { |comp|
              comp.string_painted = true
            }
        
        label 'bold/red + Verdana 16 (default)'
        progress :name => :bold
            swing { |comp|
              comp.string_painted = true
            }
        
        label 'Magenta + Verdana 16 (default)'
        progress :horizontal, :style_class => :magenta
            swing { |comp|
              comp.string_painted = true
            }
            
        label 'Magenta + italic + Verdana 16 (default)'
        progress :horizontal, :name => :italic_only, :style_class => :magenta
            swing { |comp|
              comp.string_painted = true
            }
            
        label 'COURIER 20/gray'
        progress :name => :courier
            swing { |comp|
              comp.string_painted = true
            }
        
        command '+' do
          6.times { |i| context[2 + i * 2].value = context[2 + i * 2].value + 10 }
        end
        command '-' do
          6.times { |i| context[2 + i * 2].value = context[2 + i * 2].value - 10 }
        end
        
      }
      
      visible true
      
    }
    
  end

end
