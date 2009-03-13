#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/text'

class InputOptionsTest < ManualTest

  manual 'Syntax: input label, value' do
    
    f = frame :flow do

      title "Syntax: input label, value"

      content do
        input "Name:", "James Bond"
      end

      width 300

    end

    f.visible = true

  end
  
  manual 'Syntax: input value' do

    f = frame :flow do

      title "Syntax: input value"

      content do
        input "James Bond"
      end

      width 300

    end

    f.visible = true

  end
  
  manual 'Syntax: input &options' do
      
    f = frame :flow do

      title "Syntax: input &options"

      content do
        input do
          label "Name:"
          text "James Bond"
        end
      end

      width 300

    end

    f.visible = true

  end
  
  manual 'Syntax: input hash' do
    
    f = frame :flow do

      title "Syntax: input hash"

      content do
        input :text => "James Bond", :label => "Name"
      end

      width 300

    end

    f.visible = true

  end
  
  manual 'Syntax: input value &options' do
    
    f = frame :flow do

      title "Syntax: input value &options"

      content do
        input "James Bond", :more_options do
          label "Name:"
        end
      end

      width 400

    end

    f.visible = true

  end
  
end