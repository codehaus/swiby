#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

def create_test(a_title, options = nil, &block)

  def_options = {:layout => :stacked, :align => :center, :vgap => 10, :hgap => 10}
  def_options.merge!(options) if options
  
  frame {

    title "#{a_title}"

    if block.nil?
      content(def_options) {
        input 'Input:', ''
        button 'Button 1'
        button 'Button 2'
      }
    else
      content def_options, &block
    end

    width 450
    height 200

    visible true

  }
  
end

class StackedLayoutTest < ManualTest

  manual 'centered' do
    create_test 'layout, centered'
  end
  
  manual 'centered, maximum size' do
    create_test 'stacked layout, centered, maximum size', :sizing => :maximum
  end
  
  manual 'align left, maximum size' do
    create_test 'stacked layout, align left, maximum size', :sizing => :maximum, :align => :left
  end
  
  manual 'align right, maximum size' do
    create_test 'stacked layout, align right, maximum size', :sizing => :maximum, :align => :right
  end

  manual 'horizontally, centered, maximum size' do
    create_test 'stacked horizontally, centered, maximum size', :sizing => :maximum, :align => :center, :direction => :horizontal
  end
  
  manual 'horizontally, align left, maximum size' do
    create_test 'stacked horizontally, align left, maximum size', :sizing => :maximum, :align => :left, :direction => :horizontal
  end
  
  manual 'horizontally, align right, maximum size' do
    create_test 'stacked horizontally, align right, maximum size', :sizing => :maximum, :align => :right, :direction => :horizontal
  end
  
  manual 'center, right and left aligned' do
    create_test('stacked layout: center, right and left aligned', :sizing => :maximum) {
      input 'Input:', ''
      align :right
      button 'Button 1'
      align :left
      button 'Button 2'
    }
  end

  manual 'with bottom part' do
    create_test('stacked layout with bottom part', :sizing => :maximum) {
      input 'Input:', ''
      bottom
        button 'Button 1'
        button 'Button 2'
    }
  end

  manual 'w/ bottom right part' do
    create_test('stacked layout, w/ bottom right part', :sizing => :maximum) {
      input 'Input:', ''
      bottom 
        align :right
        button 'Button 1'
        button 'Button 2'
    }
  end
  
  manual 'horizontally, w/ bottom part' do
    create_test('stacked horizontally, w/ bottom part', :sizing => :maximum, :direction => :horizontal) {
      input 'Input:', ''
      bottom
        button 'Button 1'
        button 'Button 2'
    }
  end
  
end
