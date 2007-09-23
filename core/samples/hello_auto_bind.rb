require 'swiby'

class HelloWorldModel
	attr_accessor :saying
end

model = HelloWorldModel.new 

model.saying = "Hello World"

Frame {
	
	title "Hello World F3"
	
	width 200
	
	content {
		Label {
			text bind { model.saying }
		}
	}
	
	visible true
	
	dispose_on_close
	
}

["New value...", "Good morning...", "A break?", "Let's go on!", "Hello World F3"].each { |text|
	sleep 2
	model.saying = text
}

