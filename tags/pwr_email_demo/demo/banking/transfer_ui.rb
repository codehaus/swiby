#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'transfer'
require 'account_ui'

class Transfer

  def table_row
    [@account_from.humanize, @account_to.humanize, @amount.to_s, @value_date.to_s]
  end

  def humanize
    "#{@amount} to #{@account_to.humanize}"
  end

end
