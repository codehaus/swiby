#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'iconv'

class String
  def to_utf8
    Iconv.conv('utf-8', 'ISO-8859-1', self)
  end
end
