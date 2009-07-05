#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout/grid'

require 'swiby/component/text'
require 'swiby/component/label'

class GridLayoutTest < ManualTest

  manual 'Test column span' do
    
    form {

      title "Column Span Test"

      content {

        grid(:columns => 4) {
          button 'A'
          button 'B'
          button 'C'
          button 'D'

          button 'E'
          button 'F'
          column :span => 2
            button "span 2", :name => :result

          button 'G'
          button 'H'
          button 'I'
          button 'J'
          
          column :span => 3
            button "span 3", :name => :result
          button 'K'
        }

      }

      visible true
      
    }

  end

  manual 'Test column definition with string' do

    form {

      title "String Column Definition Test"

      content {

        grid(:columns => "[][][]") {
          button 'A'
          button 'B'
          button 'C'

          button 'D'
          button 'E'
          button 'F'

          button 'G'
          button 'H'
          button 'I'
          
          button 'K'
        }

      }

      visible true

    }

  end

  manual 'Test column spacing' do

    form {

      title "Column Spacing Test"

      content {

        grid(:columns => "[grow][grow][grow]20[grow]") {
          button '7'
          button '8'
          button '9'
          button '/'

          button '4'
          button '5'
          button '6'
          button 'x'
          
          button '1'
          button '2'
          button '3'
          button '-'

          button '0'
          button '+/-'
          button '.'
          button '+'

        }

      }

      visible true

    }

  end

end