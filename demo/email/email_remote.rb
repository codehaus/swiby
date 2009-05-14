#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

#
# Run this script with '-json' switch to use JSON exhcange format,
# otherwise it uses Ruby format
#
# see comment about required gems in pwr_remoting
#

#
# This script is just testing the Email PWR demo, it outputs results
# to the console
#

require 'pwr_remoting'

options = parse_remoting_options(ARGV)

if options.use_json
  puts 'Using JSON format'
  require 'json'
else
  puts 'Using Ruby format'
end

auth = Auth.new(create_connection(options))

unless auth.login('Gil Bates', '1234')
#unless auth.login('Beeve Salmer', '1234')
  puts auth.last_error[:message]
  exit
end

puts '::inbox'
p auth.inbox.messages
puts '::sent'
p auth.sentbox.messages

puts '::read message 1'
p auth.inbox.read 1

puts '::read message 1999'
unless auth.inbox.read 1999
  puts auth.inbox.last_error[:message]
end

=begin
puts '::delete 1'
unless auth.inbox.delete 1
  puts auth.inbox.last_error[:message]
end

puts '::inbox'
p auth.inbox.messages
=end

puts '::delete 7777'
unless auth.inbox.delete 7777
  puts auth.inbox.last_error[:message]
end

puts '::send mail + show sent box'
auth.sentbox.send 'news', 'Misual Vasic .ORG', 'James Bond'
p auth.sentbox.messages

auth.logout
