#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby
  
  class Menu < SwingBase

    container :items

    def initialize
      @component = JMenu.new
    end

    def text=(t)
      @component.text = t
    end

    def text(t)
      @component.text = t
    end

    def mnemonic(char)
      @component.mnemonic = char[0]
    end

  end

  class MenuItem < SwingBase

    def initialize
      @component = JMenuItem.new
    end

    def accelerator(&block)

      acc = Accelerator.new
      acc.instance_eval( &block )

      @component.accelerator = acc.java_accelerator

    end

    def text=(t)
      @component.text = t
    end

    def text(t)
      @component.text = t
    end

    def mnemonic(char)
      @component.mnemonic = char[0]
    end

    def action(&block)

      listener = ActionListener.new

      @component.addActionListener(listener)

      listener.register(&block)

    end

  end

end