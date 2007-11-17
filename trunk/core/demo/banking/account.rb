#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class Account
  attr_accessor :owner, :number, :address, :type

  def initialize type, owner, number, address
    @type = type
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

    s = @number.to_s

    "#{s[0..2]}-#{s[3..9]}-#{s[10..11]}"

  end

  def display_icon
    
    unless @savings_icon
      @current_icon = create_icon File.join(File.dirname(__FILE__), 'images', 'bundle.png')
      @savings_icon = create_icon File.join(File.dirname(__FILE__), 'images', 'piggy-bank.png')
    end

    case @type
    when :current
      return @current_icon
    when :savings
      return @savings_icon
    end
    
  end
  
  def self.find_from_accounts

    return @from_list if not @from_list.nil?

    acc1 = Account.new :current, 'Jean / Current', '555123456733', 'Somewhere 200'
    acc2 = Account.new :current, 'Jean / Current (2)', '555765432136', 'Somewhere 200'
    acc3 = Account.new :savings, 'Jean / Savings', '111765943218', 'Somewhere 200'

    @from_list = [acc1, acc2, acc3]

  end

  def self.find_to_accounts

    return @to_list if not @to_list.nil?

    acc1 = Account.new :current, 'Max', '222764399497', 'There 14'

    @to_list = [acc1]

  end

  def table_row
    [@owner.to_s, humanize, @address.to_s]
  end

end
