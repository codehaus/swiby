#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'transfer_ui'

from_accounts = Account.find_from_accounts
to_accounts = Account.find_to_accounts

current = Transfer.new 0, from_accounts[2], to_accounts[0]

title "Transfer Form"

content {
  data current
  input "Date", :value_date
  section
  input "Amount", :amount
  next_row
  section "From"
  combo "Account", from_accounts, :account_from do |selection| 
      context['account_from.owner'].value = selection.owner
      context['account_from.address'].value = selection.address
  end
  input "Name", :account_from / :owner, :readonly => true
  input "Address", :account_from / :address, :readonly => true
  section "To"
  input "Account", :account_to / :number
  input "Name", :account_to / :owner
  input "Address", :account_to / :address
  command "Save beneficiary"
  next_row
  commands :apply, :restore
}

$context.apply_styles $context.session.styles if $context.session.styles
$context.start
