
require 'swiby'

colors = [:black, :blue, :green, :pink, :red, :white, :yellow]

##---------------------------------------------
f = frame :left_flow do

  title "Syntax: combo label, values, selected &action"

  content do
    combo 'Color:', colors, :blue do |color|
      message_box "Selected #{color}"
    end
  end

  width 400

end

f.visible = true

##---------------------------------------------
f = frame :left_flow do

  title "Syntax: combo label, values &action"

  content do
    combo 'Color:', colors do |color|
      message_box "Selected #{color}"
    end
  end

  width 400

end

f.visible = true

##---------------------------------------------
f = frame :left_flow do

  title "Syntax: combo values &action"

  content do
    combo colors do |color|
      message_box "Selected #{color}"
    end
  end

  width 400

end

f.visible = true

##---------------------------------------------
f = frame :left_flow do

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

##---------------------------------------------
f = frame :left_flow do

  title "Syntax: combo hash &action"

  content do
    combo :label => "Color:", :values => colors, :selected => :blue do |color|
        message_box "Selected #{color}"
    end
  end

  width 400

end

f.visible = true
