require 'swiby'

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
      text bind(model, :saying)
    }
  }

  visible true

}

["New value...", "Good morning...", "A break?", "Let's go on!", "Hello World F3"].each { |text|
  sleep 2
  model.saying = text
}

