#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class ButtonOptionsTest < ManualTest

  Defaults.height = 100

  image = File.join(File.dirname(__FILE__), '..',  '..', 'lib', 'swiby', 'images', 'go-previous.png')

  manual 'Syntax: button title &action' do
    
    f = frame do

      title "Syntax: button title &action"

      content do
        button "Push Me!" do
          message_box 'Hello'
        end
      end

      width 300

    end

    f.visible = true
  end

  manual 'Syntax: button icon &action' do
    
    f = frame do

      title "Syntax: button icon &action"

      content do
        button create_icon(image) do
          message_box 'Hello'
        end
      end

      width 300

    end

    f.visible = true
    
  end

  manual 'Syntax: button text, icon &action' do
    
    f = frame do

      title "Syntax: button text, icon &action"

      content do
        button "Push Me", create_icon(image) do
          message_box 'Hello'
        end
      end

      width 350

    end

    f.visible = true
  
  end
  
  manual 'Syntax: button &options' do
    
    f = frame do

      title "Syntax: button &options"

      content do
        button do
          text "Push Me"
          icon image
          action proc {message_box 'Hello'}
        end
      end

      width 300

    end

    f.visible = true

  end
  
  manual 'Syntax: button hash &action' do
    
    f = frame do

      title "Syntax: button hash &action"

      content do
        button :text => "Push Me", :icon => create_icon(image) do
          message_box 'Hello'
        end
      end

      width 300

    end

    f.visible = true

  end
  
  manual 'Syntax: button text, :more_options &options' do
    
    f = frame do

      title "Syntax: button text, :more_options &options"

      content do
        button "Push Me", :more_options do
          icon image
          action proc {message_box 'Hello'}
        end
      end

      width 400

    end

    f.visible = true

  end
  
end