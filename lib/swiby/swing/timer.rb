#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import javax.swing.Timer

module Swiby

  def every delay_millis, &handler
    
    listener = ActionListener.new
    listener.register &handler
    
    t = Timer.new(delay_millis, listener)
    t.setInitialDelay(0)
    t.start
    
    t
    
  end

  def after delay_millis, &handler
    
    listener = ActionListener.new
    listener.register &handler
    
    t = Timer.new(delay_millis, listener)
    t.repeats = false
    t.start
    
    t
    
  end

end