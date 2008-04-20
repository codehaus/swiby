#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/form'

form {
  
  title "Test handler called"
  
  width 220
  height 70

  check "Select me (x)", :x do
    puts "Is it selected? #{context[:x].selected?}"
  end

  check "Change x", :y do
    context[:x].selected = context[:y].selected
  end
  
  visible true
  
}
