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
    include_class 'javax.swing.event.DocumentListener'
    include_class 'javax.swing.event.HyperlinkEvent'
    include_class 'javax.swing.event.HyperlinkListener'
    include_class 'javax.swing.event.ListSelectionListener'
    include_class 'javax.swing.event.TreeSelectionListener'
  end

  module AWT
    include_class 'java.awt.Toolkit'
    include_class 'java.awt.AWTEvent'
    include_class 'java.awt.event.KeyEvent'
    include_class 'java.awt.event.MouseAdapter'
    include_class 'java.awt.event.MouseMotionAdapter'
    include_class 'java.awt.event.WindowAdapter'
    include_class 'java.awt.event.ActionListener'
    include_class 'java.awt.event.AWTEventListener'
    include_class 'java.awt.event.HierarchyBoundsListener'
  end

  module Java
    include_class 'java.beans.PropertyChangeListener'
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

  class TreeSelectionListener

    include Swing::TreeSelectionListener

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

  class DocumentListener
    
    include Swing::DocumentListener

    def register(&handler)
      @handler = handler
    end

    def insertUpdate(evt)
      @handler.call(evt)
    end

    def removeUpdate(evt)
      @handler.call(evt)
    end

    def changedUpdate(evt)
    end
    
  end
  

  # Components using <tt>HierarchyBoundsListener</tt> implementors generated 
  # 2 events: resize and move.
  # 
  # If the listener is not interrested in both, it can register for one of 
  # them only (see #register).
  # 
  # == Examples
  # 
  # === Example 1: Registering for resized event only
  #   listener = HierarchyBoundsListener.new
  #   
  #   listener.register :resized do
  #     puts "resized"
  #   end
  #   
  #   panel.addHierarchyBoundsListener(listener)
  #   
  #   
  # === Example 2: Registering for moved event only
  #   listener = HierarchyBoundsListener.new
  #   
  #   listener.register :moved do
  #     puts "moved"
  #   end
  #   
  #   panel.addHierarchyBoundsListener(listener)
  #   
  #   
  # === Example 3: Registering for both events
  #   listener = HierarchyBoundsListener.new
  #   
  #   listener.register do
  #     def moved ev
  #       puts "moved"
  #     end
  #     def resized ev
  #       puts "resized"
  #     end
  #   end
  #   
  #   panel.addHierarchyBoundsListener(listener)
  #
  class HierarchyBoundsListener

    include AWT::HierarchyBoundsListener
    
    # Valid values for +event+ are +:resized+ and +:moved+.
    def register(event = nil, &handler)
      
      @handler = handler
      @event_type = event
      
      @event_type = :any unless event
      
      if @event_type == :any
        handler.instance_eval(&handler)
      end
      
    end

    def ancestorMoved ev
      
      if @event_type == :any
        @handler.moved(ev)
      elsif @event_type == :moved
        @handler.call(ev)
      end
      
    end

    def ancestorResized ev
      
      if @event_type == :any
        @handler.resized(ev)
      elsif @event_type == :resized
        @handler.call(ev)
      end
      
    end

  end
  
  class MouseListener < AWT::MouseAdapter
   
    def register(&handler)
      @handler = handler
    end

    def mouseClicked ev
      @handler.on_click(ev) if @handler.respond_to?(:on_click)
    end
   
    def mouseEntered ev
      @handler.on_mouse_over(ev) if @handler.respond_to?(:on_mouse_over)
    end
   
    def mouseExited ev
      @handler.on_mouse_out(ev) if @handler.respond_to?(:on_mouse_out)
    end
    
  end
  
  class MouseMotionListener < AWT::MouseMotionAdapter
   
    def register(&handler)
      @handler = handler
    end

    def mouseDragged ev
      @handler.on_mouse_drag(ev) if @handler.respond_to?(:on_mouse_drag)
    end
   
    def mouseMoved ev
      @handler.on_mouse_move(ev) if @handler.respond_to?(:on_mouse_move)
    end
    
  end
  
end