require 'swiby'

class HelloWorldModel
	attr_accessor :saying
end

model = HelloWorldModel.new 

model.saying = "Hello World"

Frame {
	
	title bind {"#{model.saying} F3"}
	
	width 200
	
	content {
		TextField {
			value bind(model, :saying)
		}
	}
	
	visible true
	
}


["3", "2", "1", "Hello"].each { |text|
	model.saying = text
	sleep 2
}

