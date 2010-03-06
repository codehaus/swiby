#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

$LOAD_PATH << File.dirname(__FILE__)

Swiby::CONTEXT.add_translation_bundle "translations", :en, :fr

class TooltipProviderTest < ManualTest

  manual 'Automatic provider' do
    
    form {
      
      title 'Automatic provider'
      
      width 400
      height 200
      
      tooltip_provider :auto
      
      label 'label 1', :line_1
      label 'label 2', :line_2
      
      button('Change language') {
        Swiby::CONTEXT.language = Swiby::CONTEXT.language == :en ? :fr : :en
      }
      
      label "<html><h3>Tooltip comes from resource bundle<br>using component's name.<br>
              Only the two labels should have a tooltip"
      
      visible true
      
    }

  end

  manual 'Dynamic provider' do
    
    form {
      
      title 'Dynamic provider'
      
      width 400
      height 200
      
      @value = 0
      
      tooltip_provider { |name, comp|
        "Value = #{@value}"
      }
      
      label 'label 1', :label_1
      label 'label 2', :label_2
      
      button('Change value') {
        @value += 1
        context.refresh_tooltips
      }
      
      label '<html><h3>Click the change the button to increment<br>the value and check that tooltips are updated'
      
      visible true
      
    }

  end
  
end
