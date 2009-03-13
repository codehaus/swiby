#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'transfer_ui'

require 'swiby/component/table'

transfers = Transfer.find

title "Transfer List"

content {
  section "Transfer List"
  table ["From", "To", "Amount", "Date"], bind {transfers}
  button("Add") {
    $context.goto "transfer_form.rb"
  }
  button("Edit") {
    $context.goto "transfer_form.rb"
  }
}

$context.apply_styles $context.session.styles if $context.session.styles
$context.start