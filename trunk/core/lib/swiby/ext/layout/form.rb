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
  
  class FormExtension < Extension
    include LayoutExtension
  end

  class FormFactory
  
    def accept name
      name == :form
    end
    
    def create name, data
          
      layout = FormLayout.new

      layout.hgap = data[:hgap] if data[:hgap]
      layout.vgap = data[:vgap] if data[:vgap]

      layout

    end
    
  end
  
  LayoutFactory.register_factory(FormFactory.new)
  
end