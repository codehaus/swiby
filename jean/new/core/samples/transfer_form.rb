#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/form'
require 'swiby/data'

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
