#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'time'

class DateConverter
  
  def initialize format = nil
  end
  
  def internal_value_to_ui value
  
    return '' unless value
    
    "%02d%02d%04d" % [value.day, value.month, value.year]
    
  end
  
  def ui_value_to_internal value
    Time.mktime(value[4..7], value[2..3], value[0..1]) if value
  end
  
  def plug_input_formatter component
    component.input_mask '##/##/####'
  end
  
end
