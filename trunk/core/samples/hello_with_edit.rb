=begin
require 'swiby'
require 'swiby/component/frame'
require 'swiby/component/text'

class HelloWorldModel
	attr_accessor :saying
end

model = HelloWorldModel.new 

model.saying = "Hello World"

frame {
	
	title bind {"#{model.saying} F3"}
	
	width 200
	
	content {
		input {
			text bind(model, :saying)
		}
	}
	
	visible true
	
}


["3", "2", "1", "Hello"].each { |text|
	model.saying = text
	sleep 2
}
=end

puts 'Unfortunelty auto-binding does not work anymore'
puts '(with latest JRuby versions).'
puts 'Need to change approach to make it work again...'