require 'swiby'
require 'swiby/component/frame'
require 'swiby/component/label'

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
      label bind(model, :saying)
    }
  }

  visible true

}

["New value...", "Good morning...", "A break?", "Let's go on!", "Hello World F3"].each { |text|
  sleep 2
  model.saying = text
}

