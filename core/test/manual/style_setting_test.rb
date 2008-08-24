#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class StyleSettingTest < ManualTest

  manual 'Style from variable from' do
    
    styles = create_styles {
      root(
          :font_family => Styles::VERDANA,
          :font_style => :normal,
          :font_size => 10,
          :color => :white,
          :background_color => 0x494980
      )
    }
  
    form {

      title 'Set styles from variable (blue)'
      
      use_styles styles
      
      width 400
      height 130
      
      button "Hello"
      input "Name: ", "Joe"
      combo "Country:", ['Belgium', 'France', 'Italy']
      
      visible true
      
    }

  end
  
  manual 'Embedded in form styles' do
    
    form {

      title 'Set styles within form build (red)'
      
      use_styles {
        root(
          :font_family => Styles::VERDANA,
          :font_style => :normal,
          :font_size => 10,
          :color => :white,
          :background_color => 0x804949
        )    
      }
      
      width 400
      height 130
      
      button "Hello"
      input "Name: ", "Joe"
      combo "Country:", ['Belgium', 'France', 'Italy']
      
      visible true
      
    }

  end
  
  manual 'Styles from file' do
    
    form {

      title 'Load styles from file (green)'
      
      use_styles 'my_styles.rb'
      
      width 400
      height 130
      
      button "Hello"
      input "Name: ", "Joe"
      combo "Country:", ['Belgium', 'France', 'Italy']
      
      visible true
      
    }

  end
  
  manual 'Default unchanged' do
    
    form {

      title 'Previous styles don\'t change default'
      
      width 400
      height 130
      
      button "Hello"
      input "Name: ", "Joe"
      combo "Country:", ['Belgium', 'France', 'Italy']
      
      visible true
      
    }
        
  end
  
end
