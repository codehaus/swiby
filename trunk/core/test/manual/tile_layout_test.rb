#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout/tile'

require 'swiby/component/text'
require 'swiby/component/label'
require 'swiby/component/button'

import java.awt.Color

def yellow_panel label, value
  panel {input label, value}
  swing { |comp| comp.background = Color::YELLOW }
end

class TileLayoutTest < ManualTest

  manual 'Tile layouts...' do
    
    frame(:layout => :tile) {
      
      title "Tile layouts..."
    
      width 200
      height 200
      
      button "Button 1"
      label 'hello'
      label 'one step below'
      button 'stop it!'
      input "Name", "James"
      button "Button 1"
      input "Code", "007"
      input "Nickname", "Bond"
      input "Address", "secret"
      input "Email", "007@secret.org"
      
      visible true
      
    }

  end
  
  manual 'Tile w/ edit fields in panels' do
    
    frame(:layout => :tile) {
      
      title "Tile w/ edit fields in panels"
    
      width 340
      height 200
      
      button "Button 1"
      label 'hello'
      label 'one step below'
      button 'stop it!'
      yellow_panel "Name", "James"
      button "Button 1"
      yellow_panel "Code", "007"
      yellow_panel "Nickname", "Bond"
      yellow_panel "Address", "secret"
      yellow_panel "Email", "007@secret.org"
      
      visible true
      
    }

  end
  
end