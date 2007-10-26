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

require 'swiby_form'

class Account
  attr_accessor :owner, :number, :address

  def initialize owner, number, address
    @owner = owner
    @number = number
    @address = address
  end

  def humanize
    "#{@number.to_s}"
  end

end

class Transfer
  attr_accessor :amount, :account_from, :account_to

  def initialize amount, from, to
    @amount = amount
    @account_from = from
    @account_to = to
  end

end

acc1 = Account.new 'Jean', '555123456733', 'Somewhere 200'
acc2 = Account.new 'Jean (2)', '555765432136', 'Somewhere 200'
acc3 = Account.new 'Jean (3)', '111765943218', 'Somewhere 200'
acc4 = Account.new 'Max', '222764399497', 'There 14'

my_accounts = [acc1, acc2, acc3]

current = Transfer.new 200, acc1, acc4

transfer_form = form {

  title "Transfer Form"

  width 400

  content {
    input "Date", Time.now
    section
    input "Amount", bind { current.amount }
    next_row
    section "From"
    combo "Account", bind { my_accounts }, acc3
    input "Name", bind { current.account_from.owner }
    input "Address", bind { current.account_from.address }
    section "To"
    input "Account", bind { current.account_to.number }
    input "Name", bind { current.account_to.owner }
    input "Address", bind { current.account_to.address }
    next_row
    button "Save" do
      message_box("Save data!")
    end
    button "Cancel"
    next_row
  }

}

transfer_form.visible = true
