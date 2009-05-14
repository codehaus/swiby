#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class ComboOptionsTest < ManualTest

  colors = [:black, :blue, :green, :pink, :red, :white, :yellow]

  manual 'Syntax: combo label, values, selected &action' do

    f = frame :flow do

      title "Syntax: combo label, values, selected &action"

      content do
        combo 'Color:', colors, :blue do |color|
          message_box "Selected #{color}"
        end
      end

      width 400

    end

    f.visible = true

  end
  
  manual 'Syntax: combo label, values &action' do
    
    f = frame :flow do

      title "Syntax: combo label, values &action"

      content do
        combo 'Color:', colors do |color|
          message_box "Selected #{color}"
        end
      end

      width 400

    end

    f.visible = true

  end

  manual 'Syntax: combo values &action' do
    
    f = frame :flow do

      title "Syntax: combo values &action"

      content do
        combo colors do |color|
          message_box "Selected #{color}"
        end
      end

      width 400

    end

    f.visible = true

  end
  
  manual 'Syntax: combo &option' do
    
    f = frame :flow do

      title "Syntax: combo &option"

      content do
        combo do
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
  
  manual 'Syntax: combo hash &action' do
    
    f = frame :flow do

      title "Syntax: combo hash &action"

      content do
        combo :label => "Color:", :values => colors, :selected => :blue do |color|
            message_box "Selected #{color}"
        end
      end

      width 400

    end

    f.visible = true

  end

end
