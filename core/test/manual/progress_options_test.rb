#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/progress_bar'

class ProgressOptionsTest < ManualTest

  manual 'Syntax: progress' do

    f = frame :flow do

      title "Syntax: progress / use Swing max defaults"

      content do
        
        progress
        
        button '+' do
          context[0].value = context[0].value + 10
        end
        button '-' do
          context[0].value = context[0].value - 10
        end
        
      end

      width 400

    end

    f.visible = true

  end

  manual 'Syntax: progress orientation' do

    f = frame :flow do

      title "Syntax: progress :vertical / use Swing max defaults"

      content do
        
        progress :vertical
        
        button '+' do
          context[0].value = context[0].value + 10
        end
        button '-' do
          context[0].value = context[0].value - 10
        end
        
      end

      width 400

    end

    f.visible = true

  end

  manual 'Syntax: progress orientation, name' do

    f = frame :flow do

      title "Syntax: progress :horizontal, 'p-bar' / use Swing max defaults"

      content do
        
        progress :horizontal, 'p-bar'
        
        button '+' do
          context['p-bar'].value = context['p-bar'].value + 10
        end
        button '-' do
          context['p-bar'].value = context['p-bar'].value - 10
        end
        
      end

      width 400

    end

    f.visible = true

  end

  manual 'Syntax: progress orientation, maximum, name' do

    f = frame :flow do

      title "Syntax: progress :horizontal, 30, 'p-bar'"

      content do
        
        progress :horizontal, 30, 'p-bar'
        
        button '+' do
          context['p-bar'].value = context['p-bar'].value + 10
        end
        button '-' do
          context['p-bar'].value = context['p-bar'].value - 10
        end
        
      end

      width 400

    end

    f.visible = true

  end

  manual 'Syntax: progress orientation, minimum, maximum, name' do

    f = form do

      title "Syntax: progress :horizontal, 30, 120, 'bar<i>'"

      content do
        
        label "No string"
        progress :horizontal, 30, 120, 'bar1'
        
        label "Default string"
        progress :horizontal, 30, 120, 'bar2'
            swing { |comp|
              comp.string_painted = true
            }
        progress :horizontal, 30, 120, 'bar3'
        
        label "Custom string"
        progress :horizontal, 30, 120, 'bar4'
            
        command '+' do
          context['bar1'].value = context['bar1'].value + 10
          context['bar2'].value = context['bar2'].value + 10
          context['bar3'].value = context['bar3'].value + 10
          context['bar4'].value = context['bar4'].value + 10
          context['bar4'].text = "Value = #{context['bar4'].value}"
        end
        command '-' do
          context['bar1'].value = context['bar1'].value - 10
          context['bar2'].value = context['bar2'].value - 10
          context['bar3'].value = context['bar3'].value - 10
          context['bar4'].value = context['bar4'].value - 10
          context['bar4'].text = "Value = #{context['bar4'].value}"
        end
        
      end

      width 400

    end

    f['bar3'].text = :default
    
    f.visible = true

  end
  
  manual 'Syntax: progress &options' do

    f = frame :flow do

      title "Syntax: progress &options"

      content do
        
        progress {
          orientation :horizontal
          minimum 30
          maximum 120
          name 'p-bar'
        }
        
        button '+' do
          context['p-bar'].value = context['p-bar'].value + 10
        end
        button '-' do
          context['p-bar'].value = context['p-bar'].value - 10
        end
        
      end

      width 400

    end

    f.visible = true

  end

  manual 'Syntax: progress hash' do

    f = frame :flow do

      title "Syntax: progress hash"

      content do
        
        progress :orientation => :horizontal, :minimum => 30, :name => 'p-bar', :maximum => 120
        
        button '+' do
          context['p-bar'].value = context['p-bar'].value + 10
        end
        button '-' do
          context['p-bar'].value = context['p-bar'].value - 10
        end
        
      end

      width 400

    end

    f.visible = true

  end
  
end
