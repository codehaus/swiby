#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import java.awt.Dimension
import javax.swing.JEditorPane

require 'swiby/component/label'

module Swiby
  
  module Builder
      
    def layout_list label, list
    end
    
    def layout_panel pane
    end
    
    def editor w = nil, h = nil, options = nil, &block

      ensure_section
      
      x = EditorOptions.new(context, w, h, options, &block)
      
      pane = Editor.new(x)
      
      label = nil
      
      if x[:label]
        
        name = x.delete(:name)
        
        label = SimpleLabel.new(x)
        add label
        context << label
        context.add_child label
        
        x[:name] = name
        
      end
      
      context[x[:name].to_s] = pane if x[:name]
      
      add pane
      context << pane
      layout_list label, pane if label
      layout_panel pane unless label

    end

  end
  
  class EditorOptions < ComponentOptions
    
    define "Editor" do
      
      declare :label, [String, Symbol], true
      declare :name, [String, Symbol], true
      declare :width, [Integer], true
      declare :height, [Integer], true
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      declare :readonly, [TrueClass, FalseClass, IncrementalValue], true
      
      overload :label
      overload :width, :height
      
    end
    
  end

  class Editor < SwingBase
    
    def initialize options = nil

      @component = JEditorPane.new
            
      return unless options

      self.name = options[:name].to_s if options[:name]
      self.editable = !options[:readonly] if options[:readonly]
      
      scrollable

      if options[:width] and options[:height]
        
        w = options[:width]
        h = options[:height]
        
        @scroll_pane.preferred_size = Dimension.new(w, h)

      else
        @scroll_pane.preferred_size = Dimension.new(32, 32767)
      end

    end
    
    def apply_styles styles
      
      return unless styles
      
      font = styles.resolver.find_font(:editor)
      @component.font = font if font
      
      color = styles.resolver.find_color(:editor)
      @component.foreground = color if color
      
    end
    
    def text
      @component.text
    end
    
    def value
      @component.text
    end
    
    def value=(val)
      @component.text = val
    end
      
    def document
      @component.document
    end
    
    def editor_kit= kit
      @component.editor_kit = kit
    end

    def editable?
      editable
    end

    def editable= flag
      @component.editable = flag
    end

    def on_change &block
            
      listener = DocumentListener.new

      listener.register(&block)

      @component.document.addDocumentListener(listener)
  
    end
    
  end
  
end