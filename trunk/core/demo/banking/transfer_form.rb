#--
# BSD license
# 
# Copyright (c) 2007, Jean Lazarou
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice, this list 
# of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this 
# list of conditions and the following disclaimer in the documentation and/or other
# materials provided with the distribution. 
# Neither the name of the null nor the names of its contributors may be 
# used to endorse or promote products derived from this software without specific 
# prior written permission. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
# OF THE POSSIBILITY OF SUCH DAMAGE.
#++

require 'sweb'
require 'demo/banking/bank_model'

from_accounts = Account.find_from_accounts
to_accounts = Account.find_to_accounts

current = Transfer.new 0, from_accounts[2], to_accounts[0]

title "Transfer Form"

width 400

content {
	input "Date", Time.now
	section
	input "Amount", bind { current.amount }
	next_line
	section "From"
	choice "Account", bind { from_accounts }, from_accounts[2]
	input "Name", bind { current.account_from.owner }
	input "Address", bind { current.account_from.address }
	section "To"
	input "Account", bind { current.account_to.number }
	input "Name", bind { current.account_to.owner }
	input "Address", bind { current.account_to.address }
	next_line
	button "Save"
	button "Cancel"
	next_line
	button("Forward") {
		 $context.forward
	}
	button("Back") {
		 $context.back
	}
}
    
$context.start