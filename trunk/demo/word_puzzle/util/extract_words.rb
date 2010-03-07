
unless ARGV[0]
  $stderr.puts "Missing text file argument"
  exit
end

unless File.exists?(ARGV[0])
  $stderr.puts "Cannot read file '#{ARGV[0]}'"
  exit
end

require 'set'

words = Set.new

File.open(ARGV[0], "r") do |stream|
  
  while line = stream.gets
  
    line_words = line.scan(/(\w+)/).flatten
    
    line_words.each do |word|
      words << word.downcase
    end
    
  end
  
  words.to_a.sort!.each do |word|
    puts word
  end
  
end


