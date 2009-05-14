#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout/absolute'
require 'swiby/component/text'
require 'swiby/tools/console'

class LayersTest < ManualTest

  manual 'Show hide popup layer' do
    
    form {
    
      use_styles {
        popup {
          container(
            :padding => 10,
            :border_color => :black,
            :background_color => :gray
          )
        }
      }
      
      content {
        
        input 'Input 1', ''
        input 'Input 2', ''
        input 'Input 3', ''
        input 'Input 4', ''
        input 'Input 5', ''
        
        button('Show popup', :button) {
        
          if context.layers[:popup].visible?
            context.layers[:popup].visible false
            context[:button].text = 'Show popup'
          else
            context.layers[:popup].visible true
            context[:button].text = 'Hide popup'
          end
        
        }
        
      }
      
      layer(:popup) {
      
        content(:layout => :form) {
          input 'Name:', 'James', :columns => 10
        }
        
      }
      
      visible true
      
    }
    
  end

  manual 'Layer with z-index' do
    
    f = frame {
    
      content(:layout => :absolute) {
        at [20, 10]
          label 'Input 1', :label
        at [10, 0], relative_to(:label, :right, :align)
          input 'Hello ...'
      }
      
      layer(2) {
        content(:layout => :absolute) {
          at [30, 20]
            label 'Input 2', :label_2
          at [10, 0], relative_to(:label_2, :right, :align)
            input 'Hello ...'
        }
      }
      
      layer(3) {
        content(:layout => :absolute) {
          at [40, 30]
            label 'Input 3', :label_3
          at [10, 0], relative_to(:label_3, :right, :align)
            input 'Hello ...'
        }
      }
      
      visible true
      
    }
    
    f.layers[2].visible true
    f.layers[3].visible true
    
  end
  
  manual 'Layers + console' do
    
    f = form {
    
      title 'Layers + console'
      
      content {
          input 'Input 1', 'Hello', :name => :input_1
          input 'Input 2', 'world ...'
          button('Open console') {
            open_console context
          }
      }
      
      visible true
      
    }
    
  end
  
end
