#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/layout_factory'

module Swiby

  class FormFactory
  
    def accept name
      name == :form
    end
    
    def create name, data
          
      hgap = data[:hgap] ? data[:hgap] : 0
      vgap = data[:vgap] ? data[:vgap] : 0
          
      layout = FormLayout.new hgap, vgap

      layout

    end
    
  end
  
  LayoutFactory.register_factory(FormFactory.new)
  
end