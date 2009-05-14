#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import javax.swing.JToolBar

module Swiby

  class Toolbar < SwingBase

    def initialize
      @component = JToolBar.new
    end

    def add child
      @component.add child.java_component
    end

    include Builder
    
    def separator
      @component.add_separator
    end

  end

end