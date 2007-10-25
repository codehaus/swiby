require 'swiby'

class HelloWorldModel
	attr_accessor :saying
end

model = HelloWorldModel.new 

model.saying = "Hello World"

Applet {
	
	width 200
	height 100
	
	content {
		GridPanel {
			rows 3
			columns 1
			cells [
				TextField {
					value bind(model, :saying)
				},
				Label {
					text bind {"#{model.saying} Swiby"}
				},
				Button {
					text "Change"
					action {
						model.saying = ["Blue", "Green", "Red", "White", "Hello", "Bye", "Again", "Banana", "Ha!", "Ho!"][(rand * 10).to_i]
					}
				}
			]
		}
	}
	
	visible true
	
}
