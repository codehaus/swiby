
require 'swiby'

##---------------------------------------------
f = frame :left_flow do

  title "Syntax: input label, value"

  content do
    input "Name:", "James Bond"
  end

  width 300

end

f.visible = true

##---------------------------------------------
f = frame :left_flow do

  title "Syntax: input value"

  content do
    input "James Bond"
  end

  width 300

end

f.visible = true

##---------------------------------------------
f = frame :left_flow do

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

##---------------------------------------------
f = frame :left_flow do

  title "Syntax: input hash"

  content do
    input :text => "Push Me", :label => "Name"
  end

  width 300

end

f.visible = true

##---------------------------------------------
f = frame :left_flow do

  title "Syntax: input value &options"

  content do
    input "James Bond" do
      label "Name:"
    end
  end

  width 400

end

f.visible = true
