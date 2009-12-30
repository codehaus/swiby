#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout/page'

class PageLayoutTest < ManualTest
  
  manual 'Defaults to left align' do

    frame(:layout => :page) {
      
      width 450
      height 400
      
      title "Defaults to left align"
      
      button "Center button"
        
      header
        button "Here is header"
      footer
        button "Footer button"
      
      visible true
      
    }

  end
  
  manual 'All expanded (with gaps)' do

    frame(:layout => :page, :vgap => 10, :hgap => 10) {
      
      width 450
      height 400
      
      title "All expanded (with gaps)"
      
      body :fill
        button "Center button"
        
      header :expand
        button "Here is header"
      footer :expand
        button "Footer button"
      
      visible true
      
    }

  end
  
  manual 'Center expands horizonally' do

    frame(:layout => :page, :vgap => 10, :hgap => 10) {
      
      width 450
      height 400
      
      title "Center expands horizonally"
      
      body :expand
        button "Center button"
        
      header :expand
        button "Here is header"
      footer :expand
        button "Footer button"
      
      visible true
      
    }

  end
  
  manual 'Aligned left' do

    frame(:layout => :page, :vgap => 10, :hgap => 10) {
      
      width 450
      height 400
      
      title "Aligned left"
      
      body :left
        button "Center button"
        
      header :left
        button "Here is header"
      footer :left
        button "Footer button"
      
      visible true
      
    }

  end
  
  manual 'Aligned right' do

    frame(:layout => :page, :vgap => 10, :hgap => 10) {
      
      width 450
      height 400
      
      title "Aligned right"
      
      body :right
        button "Center button"
        
      header :right
        button "Here is header"
      footer :right
        button "Footer button"
      
      visible true
      
    }

  end
  
  manual 'Aligned center' do

    frame(:layout => :page, :vgap => 10, :hgap => 10) {
      
      width 450
      height 400
      
      title "Aligned center"
      
      body :center
        button "Center button"
        
      header :center
        button "Here is header"
      footer :center
        button "Footer button"
      
      visible true
      
    }

  end
  
  manual 'Body with several components (expanding)' do

    frame(:layout => :page, :vgap => 10, :hgap => 10) {
      
      width 450
      height 400
      
      title "Body with several components (expanding)"
      
      body :expand
        button "Center button"
        label 'Some text...'
        button "Another button"
        label 'And on last text...'
        
      header
        button "Here is header"
      footer
        button "Footer button"
      
      visible true
      
    }

  end
  
  manual 'Parts order is not relevant (filling)' do

    frame(:layout => :page, :vgap => 10, :hgap => 10) {
      
      width 450
      height 400
      
      title "Parts order is not relevant"
        
      header
        button "Here is header"
      footer
        button "Footer button"
      
      body :fill
        button "Center button"
        label 'Some text...'
        button "Another button"
        label 'And on last text...'
      
      visible true
      
    }

  end
  
  manual 'All body components left aligned' do

    frame(:layout => :page, :vgap => 10, :hgap => 10) {
      
      width 450
      height 400
      
      title "All body components left aligned"
        
      header
        button "Here is header"
      footer
        button "Footer button"
      
      body :left
        button "Center button"
        label 'Some text...'
        button "Another button"
        label 'And on last text...'
      
      visible true
      
    }

  end
  
  manual 'All body components right aligned' do

    frame(:layout => :page, :vgap => 10, :hgap => 10) {
      
      width 450
      height 400
      
      title "All body components right aligned"
        
      header
        button "Here is header"
      footer
        button "Footer button"
      
      body :right
        button "Center button"
        label 'Some text...'
        button "Another button"
        label 'And on last text...'
      
      visible true
      
    }

  end
  
  manual 'All body components center aligned' do

    frame(:layout => :page, :vgap => 10, :hgap => 10) {
      
      width 450
      height 400
      
      title "All body components center aligned"
        
      header
        button "Here is header"
      footer
        button "Footer button"
      
      body :center
        button "Center button"
        label 'Some text...'
        button "Another button"
        label 'And on last text...'
      
      visible true
      
    }

  end
  
end
