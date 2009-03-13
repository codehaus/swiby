#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/form'
require 'swiby/component/text'
require 'swiby/component/combo'

require 'swiby/tools/console.rb'

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
    Account.format(@number)
  end
  
  def self.valid? acc_number
    
    return false if !acc_number.instance_of?(String)

    check_digit = acc_number[-2..-1].to_i
    acc_number = acc_number[0...-2].to_i

    cd = acc_number % 97

    if cd == 0
      return check_digit == 97
    else
      return check_digit == cd
    end
    
  end
  
  def self.format acc_number
    s = "#{acc_number.to_s}"
    "#{s[0..2]}-#{s[3..9]}-#{s[10..11]}"
  end

end

class Transfer
  
  attr_accessor :amount, :account_from, :account_to, :date

  def initialize amount, from, to
    @amount = amount
    @account_from = from
    @account_to = to
    @date = Time.new
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

current = Transfer.new 200, acc3, acc4

transfer_form = form {

  use_styles "samples/styles.rb"
  
  title "Transfer Form"

  width 450
  height 300

  content {
    
    data current
    
    input "Date", :date
    section
    input "Amount", :amount
    next_row
      section "From"
      combo("Account", my_accounts, :account_from) { |selection| 
        context['account_from.owner'].value = selection.owner
        context['account_from.address'].value = selection.address
      }
      input "Name", :account_from / :owner, :readonly => true
      input "Address", :account_from / :address, :readonly => true
      section "To"
      input "Account", :account_to / :number
      input "Name", :account_to / :owner
      input "Address", :account_to / :address
      button "Save beneficiary"
    next_row
      command(:ok, :cancel) {

        def on_validate

          acc_number = values['account_to.number'].value

          if Account.valid?(acc_number)
            true
          else
            message_box "#{Account.format(acc_number)} is not a valid account number"
            false
          end

        end

      }
    next_row
      button("Console") {
        open_console self
      }
  }
  
  on_close {
    message_box(current.summary)
  }

  exit_on_close
  
}

transfer_form.visible = true
