#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'java'

module Swiby

  module Swing
    include_class 'javax.swing.event.HyperlinkEvent'##
    include_class 'javax.swing.event.HyperlinkListener'##
    include_class 'javax.swing.event.ListSelectionListener'##
  end

  module AWT
    include_class 'java.awt.Toolkit'##
    include_class 'java.awt.AWTEvent'##
    include_class 'java.awt.event.KeyEvent'##
    include_class 'java.awt.event.WindowAdapter'##
    include_class 'java.awt.event.ActionListener'##
    include_class 'java.awt.event.AWTEventListener'##
  end

  module Java
    include_class 'java.beans.PropertyChangeListener'##
  end

  class WindowCloseListener < AWT::WindowAdapter
    
    def register(&handler)
      @handler = handler
    end

    def windowClosing(evt)
      @handler.call
    end

  end
  
  class EnterAction

    include AWT::AWTEventListener

    def register(&handler)

      AWT::Toolkit.getDefaultToolkit().addAWTEventListener(self, AWT::AWTEvent::KEY_EVENT_MASK)

      @handler = handler

    end

    def eventDispatched(evt)

      if evt.is_a? AWT::KeyEvent

        if evt.getID() == AWT::KeyEvent::KEY_PRESSED and evt.key_code == AWT::KeyEvent::VK_ENTER
          @handler.call
        end

      end

    end

  end

  class ActionListener

    include AWT::ActionListener

    def register(&handler)
      @handler = handler
    end

    def actionPerformed(evt)
      @handler.call
    end

  end

  class ListSelectionListener

    include Swing::ListSelectionListener

    def register(&handler)
      @handler = handler
    end

    def valueChanged(e)
      @handler.call
    end

  end

  class HyperlinkListener

    include Swing::HyperlinkListener

    def register(&handler)
      @handler = handler
    end

    def hyperlinkUpdate(e)
      if e.event_type == Swing::HyperlinkEvent::EventType::ACTIVATED
        @handler.call(e.description)
      end
    end

  end

  class PropertyChangeListener

    include Java::PropertyChangeListener

    def register(&handler)
      @handler = handler
    end

    def propertyChange(evt)
      @handler.call(evt.old_value, evt.new_value)
    end

  end

end