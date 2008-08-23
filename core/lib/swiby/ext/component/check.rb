#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require_extension :component, 'button'

module Swiby
  
  class CheckBoxExtension < Extension
    include ComponentExtension
  end
  
  module Builder
  
    def check text = nil, image = nil, options = nil, &block
      
      but = button_factory(text, image, options, block) do |opt|
        CheckBox.new(opt)
      end
      
      layout_list nil, but
      
      but
      
    end
 
  end

  class CheckBox < Button

    def create_button_component
      JCheckBox.new
    end
    
  end
  
end