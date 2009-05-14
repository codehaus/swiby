#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class ListOptionsTest < ManualTest

  colors = [:black, :blue, :green, :pink, :red, :white, :yellow]

  manual 'Syntax: list label, values, selected &action' do

    f = frame :flow do

      title "Syntax: list label, values, selected &action"

      content do
        list 'Color:', colors, :blue do |color|
          message_box "Selected #{color}"
        end
      end

      width 400

    end

    f.visible = true

  end
  
  manual 'Syntax: list label, values &action' do
    
    f = frame :flow do

      title "Syntax: list label, values &action"

      content do
        list 'Color:', colors do |color|
          message_box "Selected #{color}"
        end
      end

      width 400

    end

    f.visible = true

  end
  
  manual 'Syntax: list values &action' do
    
    f = frame :flow do

      title "Syntax: list values &action"

      content do
        list colors do |color|
          message_box "Selected #{color}"
        end
      end

      width 400

    end

    f.visible = true

  end
  
  manual 'Syntax: list &option' do
    
    f = frame :flow do

      title "Syntax: list &option"

      content do
        list do
          label "Color:"
          values colors
          selected :blue
          action proc { |color|
            message_box "Selected #{color}"
          }
        end
      end

      width 400

    end

    f.visible = true

  end
  
  manual 'Syntax: list hash &action' do
    
    f = frame :flow do

      title "Syntax: list hash &action"

      content do
        list :label => "Color:", :values => colors, :selected => :blue do |color|
            message_box "Selected #{color}"
        end
      end

      width 400

    end

    f.visible = true
  
  end

end