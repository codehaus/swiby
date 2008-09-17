#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby
  
  class ShortcutExtension < Extension
    include ComponentExtension
  end
  
  class KeyHandler
    
    attr_reader :key_strokes
    
    def initialize key_stroke, &handler
      @handler = handler
      @key_strokes = [key_stroke]
    end
    
    def process ev
       @handler.call
    end
    
  end
  
  def cr_key &block
    
    ks = javax.swing.KeyStroke.getKeyStroke('ENTER')
    
    return ks unless block
    
    KeyHandler.new(ks, &block)
    
  end
  
  def esc_key &block
    
    ks = javax.swing.KeyStroke.getKeyStroke('ESCAPE')
    
    return ks unless block
    
    KeyHandler.new(ks, &block)
    
  end
  
  def ctl_key decorated_key
    javax.swing.KeyStroke.getKeyStroke(decorated_key.key_code, java.awt.event.InputEvent::CTRL_MASK)
  end
    
  def global_shortcut *keys, &block
    
    kl = KeyEventListener.new
    
    kl.register *keys, &block
    
  end
  
  module Builder
    
    def shortcut *keys, &block
    
      kl = KeyEventListener.new
      
      kl.register_for_component context.java_component, *keys, &block
      
    end
    
  end

end