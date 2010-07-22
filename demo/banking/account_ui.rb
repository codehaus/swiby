#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'account'

class Account

  alias :model_init :initialize
  
  def initialize type, owner, number, address
    model_init type, owner, number, address
    add_ui_methods
  end

  def number= acc_num
    @number = acc_num
    add_ui_methods
  end
  
  def add_ui_methods
    
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
      
      return nil if @load_done
      
      @current_icon = create_icon 'images/bundle.png'
      @savings_icon = create_icon 'images/piggy-bank.png'

      @load_done = true
      
      return nil unless @savings_icon
        
    end

    case @type
    when :current
      return @current_icon
    when :savings
      return @savings_icon
    end
    
  end
  
  def table_row
    [@owner.to_s, @type.to_s.capitalize, humanize, @address.to_s]
  end

  def self.update_existing_instances

    find_from_accounts.each do |acc|
      acc.add_ui_methods
    end
    
    find_to_accounts.each do |acc|
      acc.add_ui_methods
    end
    
  end
  
  update_existing_instances
  
end
