#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class Person
  attr_accessor :name, :birth_date
  
  def initialize name, birth_date
    @name, @birth_date = name, birth_date
  end
  
end

class FormWithDataTest < ManualTest

  james = Person.new('James', Time.new)

  manual 'Access to fields' do
    
    form {
      
      data james

      title "Access to fields"
      
      content {
      
        input 'Name:', :name
        
        next_row
        
        section "Birth date"
          input "Year:", :birth_date / :year
          input "Month:", :birth_date / :month
          input "Day:", :birth_date / :day

      }
      
      visible true
      
    }

  end
  
end