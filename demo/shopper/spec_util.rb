#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class TestMethodWrapper

  def initialize(method, *values)
    @method = method
    @values = values
  end
  
  def matches?(target)
    @target = target
    @target.send(@method, *@values)
  end
  
  def failure_message
    "expected #{@target.class} to #{@method.to_s.gsub(/\?/, '')} #{@values}, but it does not"
  end
  
  def negative_failure_message
    "expected #{@target.class} not to #{@method.to_s.gsub(/\?/, '')} #{@values}, but it does"
  end
  
end