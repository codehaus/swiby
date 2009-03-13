#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'account'

class Transfer
  attr_accessor :amount, :account_from, :account_to, :value_date

  def initialize amount, from, to, value_date = Time.now
    @amount = amount
    @account_from = from
    @account_to = to
    @value_date = value_date
  end

  def self.count
    find.size
  end
  
  def self.find

    return @list if not @list.nil?

    from = Account.find_from_accounts
    to = Account.find_to_accounts

    @list = [
      Transfer.new(200, from[0], to[0]),
      Transfer.new(14, from[0], from[1]),
      Transfer.new(130, from[1], to[0])
    ]
    
  end

end
