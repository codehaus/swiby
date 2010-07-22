#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'account_ui'

require 'swiby/component/table'

accounts = Account.find_from_accounts

title "Account List"

content {
  section "Accounts"
  table(["Owner", "Type", "Number", "Address"], bind {accounts}) {
    height 100
  }
}

$context.apply_styles $context.session.styles if $context.session.styles
$context.start