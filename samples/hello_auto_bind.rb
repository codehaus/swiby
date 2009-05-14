=begin
require 'swiby'
require 'swiby/component/text'
require 'swiby/component/frame'

class HelloWorldModel
	attr_accessor :saying
end

model = HelloWorldModel.new 

model.saying = "Hello World"

frame {
	
	title "Hello World F3"
	
	width 200
	
	content {
		label {
			label bind { model.saying }
		}
	}
	
	visible true
	
}

["New value...", "Good morning...", "A break?", "Let's go on!", "Hello World F3"].each { |text|
	sleep 2
	model.saying = text
}
=end

puts 'Unfortunelty auto-binding does not work anymore'
puts '(with latest JRuby versions).'
puts 'Need to change approach to make it work again...'