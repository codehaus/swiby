#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class Fixnum
  
  def euros
    @currency = :euro
    self
  end
  
  def dollars
    @currency = :dollar
    self
  end
  
  def plug_input_formatter field
    field.currency @currency
  end
  
end

class Time
  
  def input_mask= mask
    @input_mask = mask.to_s
    self
  end
  
  def plug_input_formatter field
    field.date(@input_mask) if @input_mask
  end
  
end