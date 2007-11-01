#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'sweb'
require 'demo/banking/transfer'

from_accounts = Account.find_from_accounts
to_accounts = Account.find_to_accounts

current = Transfer.new 0.dollars, from_accounts[2], to_accounts[0]

title "Transfer Form"

width 400

content {
  data current
  input "Date", Time.now
  section
  input "Amount", :amount
  next_row
  section "From"
  combo "Account", from_accounts, current.account_from
  input "Name", :account_from / :owner
  input "Address", :account_from / :address
  section "To"
  input "Account", :account_to / :number
  input "Name", :account_to / :owner
  input "Address", :account_to / :address
  button "Save beneficiary"
  next_row
  apply_restore
}

$context.start
