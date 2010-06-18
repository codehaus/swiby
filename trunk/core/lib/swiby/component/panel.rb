#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import javax.swing.JPanel

module Swiby
    
  module Builder
  
    def layout_panel panel
    end
      
    def layout_list label, list
    end
    
    def group *args, &block
      panel(*args, &block)
    end
    
    def palette x, y, closeable, options = nil, &block
      
      options = options ? options : {}
      
      pane = panel(options, &block)
      
      comp = pane.java_component
      
      comp.border = org.codehaus.swiby.component.ToolboxBorder.new(comp, closeable, context.java_component.parent)

      if options[:width] and options[:height]
        comp.set_bounds x, y, options[:width], options[:height]
      else
        dim = comp.preferred_size
        comp.set_bounds x, y, dim.width, dim.height
      end
      
      pane.palette = true
      
      pane
      
    end
    
    def panel options = nil, &block

      ensure_section

      pane = create_panel(options)
      
      context.add_child pane
      
      add pane
      context << pane
      layout_panel(pane)

      pane.instance_eval(&block) unless block.nil?
    
      pane
      
    end

    def create_panel options
      
      x = options ? options : {}
      
      pane = Panel.new(x)
      
      layout = pane.java_component.getLayout
      
      if layout.respond_to?(:add_layout_extensions)
        layout.add_layout_extensions pane
      end
      
      local_context = pane #TODO pattern repeated at several places!

      pane.instance_eval do

        @local_context = local_context

        def context()
          @local_context
        end

      end
      
      if context.instance_variable_defined?(:@controller)
        pane.instance_variable_set(:@controller, context.instance_variable_get(:@controller))
      end
      
      context[x[:name].to_s] = pane if x[:name]
      
      pane
      
    end

  end

  class Panel < Container
    
    def initialize options = nil
            
      super
      
      @component = JPanel.new
      
      return unless options
      
      scrollable if options[:scrollbars]
      options.delete(:scrollbars)
      
      self.name = options[:name].to_s if options[:name]
      
      if options[:layout]
        java_component(true).layout = create_layout(options)
      end
      
      @style_id = self.name.to_sym if self.name
      @style_class = options[:style_class] if options[:style_class]
      
    end

    def palette= panel_is_palette
      @palette = panel_is_palette
    end
    
    def palette?
      @palette
    end
    
    def add(child, layout_hint = nil)
      
      if layout_hint
        @component.add child.java_component, layout_hint
      else
        @component.add child.java_component
      end
      
    end
    
    def java_container
      @component
    end
    
    def add_child child

      @children = [] unless @children
      
      @children << child
      
    end
    
    def change_language
      
      if @children
        
        @children.each do |kid|
          kid.change_language
        end
        
      end
      
    end
    
    def apply_styles styles = nil
     
      return unless styles or @styles
      
      if styles
        @styles = styles
      else
        styles = @styles
      end
      
      color = styles.resolver.find_background_color(:container, @style_id, @style_class)
      @component.background = color if color
      
      border = styles.resolver.create_border(:container, @style_id, @style_class)
      @component.border = border if border
      
      if @children
        
        @children.each do |kid|
          kid.apply_styles styles
        end
        
      end

      if self.palette?
        
        x = @component.x
        y = @component.y
        
        dim = @component.preferred_size
        @component.set_bounds x, y, dim.width, dim.height
        
      end
    
      java_component.repaint
      
    end
    
  end

end