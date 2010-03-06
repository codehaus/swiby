#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout/card'
require 'swiby/layout/border'
require 'swiby/layout/stacked'

class CardLayoutTest < ManualTest
  
  manual 'Different layouts for each card' do

    frame(:layout => :card) {
      
      title 'Different layouts for each card'
      
      content {
        card(:one) {
          label "<html><h2>First card</h2>Using flow layout"
          button('Card 2') { context.show_card(:two) }
          button('Card 3') { context.show_card(:three) }
        }
        card(:two, :layout => :border) {
          center
            label "<html><h2>Second card</h2>Using border layout"
          west
            button('Card 1') { context.show_card(:one) }
          east
            button('Card 3') { context.show_card(:three) }
        }
        card(:three, :layout => :stacked) {
          label "<html><h2>Third card</h2>Using stacked layout"
          button('Card 1') { context.show_card(:one) }
          button('Card 2') { context.show_card(:two) }
        }
      }
      
      visible true
      
    }

  end
  
  manual 'Without explicit content' do

    frame(:layout => :card) {
      
      title 'Without explicit content'
      
      card(:one) {
        label "<html><h2>First card</h2>"
        button('Next') { context.show_card(:two) }
      }
      card(:two) {
        label "<html><h2>Second card</h2>"
        button('Previous') { context.show_card(:one) }
      }
      
      visible true
      
    }

  end
  
  manual 'Adds "show_card" method to the frame object' do

    f = frame(:layout => :card) {
      
      title 'Without explicit content'
      
      card(:one) {
        label "<html><h2>First card</h2><font color=red><b>Card 2</b></font> should be default"
        button('Next') { context.show_card(:two) }
      }
      card(:two) {
        label "<html><h2>Second card</h2><font color=red><b>Card 2</b></font> should be default"
        button('Previous') { context.show_card(:one) }
      }
      
      visible true
      
    }

    f.show_card :two
    
  end
  
  manual 'With effetcs' do

    f = frame(:layout => :card, :effect => :dashboard) {
      
      title 'Without explicit content'
      
      card(:one) {
        label "<html><h2>First card</h2><font color=red><b>Card 2</b></font> should be default"
        button('Next') { context.show_card(:two) }
      }
      card(:two) {
        label "<html><h2>Second card</h2><font color=red><b>Card 2</b></font> should be default"
        button('Previous') { context.show_card(:one) }
      }
      
      visible true
      
    }
    
  end
  
end