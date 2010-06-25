GREETINGS = ["Hello", "Bonjour", "Dag", "Kalimera"]

index = rand(GREETINGS.length)

name = "Anonymous"

name = ARGV[0] if ARGV[0]

puts "#{GREETINGS[index]} #{name}"

multiline_string = "Hello,
My name is James.
I would like to be 7!
"
puts multiline_string