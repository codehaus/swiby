#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'account_ui'

account = Account.new 'Myself', '123456789', 'Here', 'current'

title "New Account"

content {
  section "New User Data" 
  
    input "Account"
    input "Type"
    input "Owner"
    input "Name"
}

$context.apply_styles $context.session.styles if $context.session.styles
$context.start