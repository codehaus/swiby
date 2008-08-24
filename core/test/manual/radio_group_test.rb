#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class RadioGroupTest < ManualTest

  manual 'Radio Group / default layout / no data' do
    
    form {
      
      title "Radio Group / default layout / no data"
      
      width 340
      height 200
      
      label 'blue should be selected'

      radio_group 'Color:', ['red', 'green', 'blue'], 'blue', :name => :color
      
      button "'green' by index" do
        context[:color].selection = 1
      end
      
      button "'red' by value" do
        context[:color].value = 'red'
      end
      
      visible true
      
    }
    
  end

  manual 'Radio Group / default layout / w/ data' do
    
    class MyColor
      
      attr_accessor :color
      
      def initialize color
        @color = color
      end
      
    end

    my_colors = MyColor.new('blue')

    form {
      
      title "Radio Group / default layout / w/ data"
      
      data my_colors
      
      width 340
      height 200
      
      label 'blue should be selected'

      radio_group 'Color:', ['red', 'green', 'blue'], :color
      
      button "'green' by index" do
        context[:color].selection = 1
      end
      
      button "'red' by value" do
        context[:color].value = 'red'
      end
      
      visible true
      
    }
    
  end

  manual 'Radio Group / horizontal / no data' do
    
    form {
      
      title "Radio Group / horizontal / no data"
      
      width 340
      height 200
      
      label 'blue should be selected'

      radio_group :horizontal, 'Color:', ['red', 'green', 'blue'], 'blue', :name => :color
      
      button "'green' by index" do
        context[:color].selection = 1
      end
      
      button "'red' by value" do
        context[:color].value = 'red'
      end
      
      visible true
      
    }

  end
  
end