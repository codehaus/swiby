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

class Account
    attr_accessor :owner, :number, :address
    
    def initialize owner, number, address
        @owner = owner
        @number = number
        @address = address
    end
		
		def humanize
		
			s = @number.to_s
		
			"#{s[0..2]}-#{s[3..9]}-#{s[10..11]}"
			
		end
		
		def self.find_from_accounts
		
			return @from_list if not @from_list.nil?
			
			acc1 = Account.new 'Jean', '555123456733', 'Somewhere 200'
			acc2 = Account.new 'Jean (2)', '555765432136', 'Somewhere 200'
			acc3 = Account.new 'Jean (3)', '111765943218', 'Somewhere 200'
			
			@from_list = [acc1, acc2, acc3]
			
		end
		
		def self.find_to_accounts
		
			return @to_list if not @to_list.nil?
			
			acc1 = Account.new 'Max', '222764399497', 'There 14'
			
			@to_list = [acc1]
			
		end
		
		def table_row
			[@owner.to_s, humanize, @address.to_s]
		end
    
end

class Transfer
    attr_accessor :amount, :account_from, :account_to, :value_date
    
    def initialize amount, from, to, value_date = Time.now
        @amount = amount
        @account_from = from
        @account_to = to
				@value_date = value_date
    end
		
		def table_row
			[@account_from.humanize, @account_to.humanize, @amount.to_s, @value_date.to_s]
		end
		
		def humanize
			"#{@amount} to #{@account_to.humanize}"
		end
		
		def self.find
		
			return @list if not @list.nil?
		
			from = Account.find_from_accounts
			to = Account.find_to_accounts
			
			@list = [
				Transfer.new(200, from[0], to[0]),
				Transfer.new(14, from[0], from[1]),
				Transfer.new(130, from[1], to[0])
			]
			
		end
    
end
