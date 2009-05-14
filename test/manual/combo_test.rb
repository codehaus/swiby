#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class ComboTest < ManualTest
  
  manual 'Combo w/ strings, handler receives strings' do
    
    form {
      
      title "Combo component / strings"
      
      width 200
      height 70

      combo ["default", "blue", "green", "purple", "red", "yellow"] do |theme|
        puts theme
      end
      
      visible true
      
    }

  end
  
  manual 'Handler receives objects' do
    
    class MyData
      
      attr_accessor :name
      
      def initialize name
        @name = name
      end

      def to_s
        @name
      end
      
    end

    form {
      
      title "Combo component / objects"
      
      width 200
      height 70

      combo([MyData.new(:a), MyData.new(:b), MyData.new(:c)]) do |data|
        puts data.name
      end
      
      visible true
      
    }
    
  end
  
end