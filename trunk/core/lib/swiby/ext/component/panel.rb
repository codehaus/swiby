#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby
    
  class PanelExtension < Extension
    include ComponentExtension
  end

  module Builder
  
    def layout_panel panel
    end
      
    def panel options = nil, &block

      ensure_section

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
      
      context[x[:name].to_s] = pane if x[:name]
      
      context.add_child pane
      
      add pane
      context << pane
      layout_panel(pane)

      pane.instance_eval(&block) unless block.nil?
    
    end

  end
  
  class Panel < Container

    def initialize options = nil
            
      super
      
      @component = JPanel.new
      
      return unless options
      
      self.name = options[:name].to_s if options[:name]
      
      if options[:layout]
        java_component.layout = create_layout(options)
      end
      
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
    
    def apply_styles styles = nil
      
      return unless styles or @styles
      
      if styles
        @style = nil
      else
        styles = @styles
      end
      
      color = styles.resolver.find_background_color(:container)
      @component.background = color if color
      
      if @children
        
        @children.each do |kid|
          kid.apply_styles styles
        end
        
      end

    end
    
  end

end