#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'test/unit'

module Swiby
  
  module Unit
    
    class DummyTestData
      attr_accessor :v1, :v2, :b3, :c4, :l5
    end
    
    def create_anonymous_form

      form {

        title "Anonymous Form"

        content {
          section 'section 1'
          input 'label 0', 'value 1'
          section "section 2"
          input 'label 2', 'value 3'
          next_row
          section "section 3"
          button 'button 4'
          next_row
          combo 'label 5', ['list 6']
        }

        dispose_on_close

      }

    end
  
    def create_same_values_form

      form {

        content {
          section 'section'
          input 'label', 'value'
          section "section"
          input 'label', 'value'
          next_row
          section "section"
          button 'button'
          next_row
          combo 'label', ['value']
        }

        dispose_on_close

      }

    end
    
    def create_values_by_symbol_form
      
      form {

        content {
          data DummyTestData.new
          section 'section'
          input 'label', :v1
          input 'label', :v2
          #TODO implement accessor path + symbol for buttons, lists and comoboxes
          #button :b3
          #next_row
          #combo 'label', :c4
          #label :l5
        }

        dispose_on_close

      }

    end
    
    def create_values_by_accesor_path_form
      
      form {

        content {
          data DummyTestData.new
          section 'section'
          input 'label', AccessorPath.new(:v1)
          input 'label', AccessorPath.new(:v2)
          #TODO implement accessor path + symbol for buttons, lists and comoboxes
          #button AccessorPath.new(:b3)
          #next_row
          #combo 'label', AccessorPath.new(:c4)
          #label AccessorPath.new(:l5)
        }

        dispose_on_close

      }

    end
    
    def create_explicit_names_form

      form {

        content {
          input {
            label 'label'
            text 'value'
            name 'v1'
          }
          input {
            label 'label'
            text 'value'
            name 'v2'
          }
          button {
            text 'button'
            name 'b3'
          }
          next_row
          combo {
            label 'label'
            values ['value']
            name 'c4'
          }
          label {
            label 'label'
            name 'l5'
          }
        }

        dispose_on_close

      }

    end

  end

end