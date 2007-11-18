#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'transfer'

transfers = Transfer.find
accounts = Account.find_from_accounts

title "Banking System"

width 400
height 500

content {
  section "Accounts"
  table(["Owner", "Number", "Address"], bind {accounts}) {
    height 100
  }
  next_row
  section "Transfer List"
  table ["From", "To", "Amount", "Date"], bind {transfers}
  button("Add") {
    $context.goto "transfer_form.rb"
  }
  button("Edit") {
    $context.goto "demo/banking/transfer_form.rb"
  }
}

$context.start