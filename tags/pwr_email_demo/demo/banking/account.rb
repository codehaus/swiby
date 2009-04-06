#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class Account
  attr_accessor :owner, :number, :address, :type

  def initialize type, owner, number, address
    @type = type
    @owner = owner
    @number = number
    @address = address
  end

  def self.count_from_accounts
    find_from_accounts.size
  end
  
  def self.find_from_accounts

    return @from_list if not @from_list.nil?

    acc1 = Account.new :current, 'Jean / Current', '555123456733', 'Somewhere 200'
    acc2 = Account.new :current, 'Jean / Current (2)', '555765432136', 'Somewhere 200'
    acc3 = Account.new :savings, 'Jean / Savings', '111765943218', 'Somewhere 200'

    @from_list = [acc1, acc2, acc3]

  end

  def self.find_to_accounts

    return @to_list if not @to_list.nil?

    acc1 = Account.new :current, 'Max', '222764399497', 'There 14'

    @to_list = [acc1]

  end

end
