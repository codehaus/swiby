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
require 'swiby_data'

class Account
  
  attr_accessor :owner, :number, :address

  def initialize owner, number, address
    @owner = owner
    @number = number
    @address = address
    
    class << @number
        
      def plug_input_formatter field
        field.input_mask '###-#######-##'
      end

    end
  end

  def humanize
    s = "#{@number.to_s}"
    "#{s[0..2]}-#{s[3..9]}-#{s[10..11]}"
  end

end

class Transfer
  
  attr_accessor :amount, :account_from, :account_to

  def initialize amount, from, to
    @amount = amount
    @account_from = from
    @account_to = to
  end

  def summary
    "<html><pre>" +
      "<b>Transfer</b> $#{@amount}<br>" +
      "    <b>From</b> #{@account_from.humanize} (#{@account_from.owner})<br>" +
      "      <b>To</b> #{@account_to.humanize} (#{@account_to.owner})</pre></html>"
  end
  
end

acc1 = Account.new 'Jean', '555123456733', 'Somewhere 200'
acc2 = Account.new 'Jean (2)', '555765432136', 'Somewhere 200'
acc3 = Account.new 'Jean (3)', '111765943218', 'Somewhere 200'
acc4 = Account.new 'Max', '222764399497', 'There 14'

my_accounts = [acc1, acc2, acc3]

current = Transfer.new 200.dollars, acc1, acc4

transfer_form = form do

  title "Transfer Form"

  width 400

  content do
    data current
    input "Date", Time.now
    section
    input "Amount", :amount
    next_row
    section "From"
    combo "Account", my_accounts, current.account_from
    input "Name", :account_from / :owner
    input "Address", :account_from / :address
    section "To"
    input "Account", :account_to / :number
    input "Name", :account_to / :owner
    input "Address", :account_to / :address
    button "Save beneficiary"
    next_row
    apply_restore
  end
  
  on_close do
    message_box(current.summary)
  end

end

transfer_form.visible = true
