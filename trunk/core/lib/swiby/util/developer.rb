#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

# print out the message (+msg+) and a stack trace showing the calling stack
def print_stack_trace msg
  
  begin
    raise RuntimeError.new(msg)
  rescue RuntimeError => er
    
    trace = er.backtrace
    trace.shift
    
    puts msg
    puts trace.join("\n")
    
  end
  
end
