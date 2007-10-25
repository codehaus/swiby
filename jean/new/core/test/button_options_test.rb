
require 'swiby'

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

f = frame do

  title "Syntax: button icon &action"
  
  content do
    button create_icon("swiby/images/go-previous.png") do
      message_box 'Hello'
    end
  end
  
  width 300

end

f.visible = true

f = frame do

  title "Syntax: button text, icon &action"
  
  content do
    button "Push Me", create_icon("swiby/images/go-previous.png") do
      message_box 'Hello'
    end
  end
  
  width 350

end

f.visible = true

f = frame do

  title "Syntax: button &options"
  
  content do
    button do
      text "Push Me"
      icon "swiby/images/go-previous.png"
      action proc {message_box 'Hello'}
    end
  end
  
  width 300

end

f.visible = true

f = frame do

  title "Syntax: button hash &action"
  
  content do
    button :text => "Push Me", :icon => create_icon("swiby/images/go-previous.png") do
      message_box 'Hello'
    end
  end
  
  width 300

end

f.visible = true

f = frame do

  title "Syntax: button text, :more_options &options"
  
  content do
    button "Push Me", :more_options do
      icon "swiby/images/go-previous.png"
      action proc {message_box 'Hello'}
    end
  end
  
  width 400

end

f.visible = true