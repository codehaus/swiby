#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout/form'

require 'swiby/component/panel'
require 'swiby/component/combo'
require 'swiby/component/check'
require 'swiby/component/label'
require 'swiby/component/editor'
require 'swiby/component/button'

require 'swiby/component/auto_hide'

class AutoHidePanelsTest < ManualTest

  manual 'One button at west-side' do
    
    f = frame {

      title 'One button at west-side'
      
      width 350
      height 200
      
      auto_hide('some tip', :west) {
        button('Clik me!') {
          message_box 'Clicked...'
        }
      }
      
      label "<html><h1>What to test?</h1><ul>
      <li>should show fading hint
      <li>should animate while showing
      <li>should hide with animation when mouse moves outside the auto-hide panel
      <li>should display a message when clicking the button
      <li>should hide the auto-hide component when resizing
      <li>should animate again if hidden because of a resize
      </ul><br><i>Note: delay at opening is intended</i>"

    }
    
    after(2000) {
      f.visible true
    }
    
  end
  
  manual "West-side don't show hint" do
    
    f = frame {

      title "West-side don't show hint"
      
      width 350
      height 200
      
      auto_hide(:no_hint, :west) {
        button('Button')
      }
      
      label "<html><h1>Hope you saw not hint?</h1>"

    }
    
    f.visible true
    
  end
  
  manual '4 auto-hide panels' do
    
    f = frame {

      title '4 auto-hide panels'
      
      width 350
      height 400
      
      auto_hide('document', :north, :layout => :flow) {
        button 'New'
        button 'Save'
        button 'Quit'
      }
    
      auto_hide('help', :west) {
        label '<html><font size=4>What to test?</font><br><br>Look at <i>One button ...</i>'
      }
      
      auto_hide('styles', :east, :layout => :form, :bg_color => Color::GREEN) {
        combo 'Font', ['Arial', 'Courier', 'Verdana']
        combo 'Size', [10, 12, 14, 16, 18, 20]
        check 'bold'
        check 'italic'
      }
      
      auto_hide('status', :south) {
        label '<html><b>Modfied</b>'
      }
      
      editor "You should see 4 hints, two with default background and the east-side in green"

      visible true
      
    }
    
  end
  
end