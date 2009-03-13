require 'swiby'
require 'swiby/component/frame'
require 'swiby/component/label'

win = Frame.new
win.title = "Hello World F3"
win.width = 200
label = SimpleLabel.new
label.text = "Hello World"
win.content = label
win.visible = true
