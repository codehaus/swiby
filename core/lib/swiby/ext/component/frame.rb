#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby
  
  class FrameExtension < Extension
    include ComponentExtension
  end

  def frame options = nil, &block

    sync_swing_thread do

      options = {:layout => :border } unless options
      options = {:layout => options } if options.is_a?(Symbol)

      options[:layout] = :border unless options[:layout]
      
      layout = create_layout(options)

      x = ::Frame.new(layout)

      if layout.respond_to?(:add_layout_extensions)
        layout.add_layout_extensions x
      end

      def x.context()
        self
      end

      if options[:controller]
        
        controller = options[:controller]
          
        controller.view = x
          
        x.instance_variable_set(:@controller, controller)
        
      end
      
      x.instance_eval(&block) unless block.nil?

      x.apply_styles

      x
    
    end

  end
  
  class Frame < Container

    @@frames = []

    def initialize layout = nil, as_dialog = false, parent = nil

      super
      
      if as_dialog
        
        @parent = parent
        
        @component = JDialog.new(parent.java_component)
        @component.modal = true
        @component.layout = layout if layout
        
        def self.java_container
          @component
        end

        def self.visible= flag

          if flag
            apply_styles
          end
          
          if !@component.visible and @width and @height
            @component.set_size @width, @height
          else
            @component.pack
          end

          w = @component.width
          h = @component.height
          
          x = (@parent.java_component.width - w) / 2 if @parent.java_component.width > w
          y = (@parent.java_component.height - h) / 2 if @parent.java_component.height > h

          @component.setBounds x, y, w, h if x and y
          
          unless @component.visible or x or y
            @component.pack if Defauls.auto_sizing_frame
          end
          
          @component.visible = flag
          
        end

        return
        
      end
      
      @@frames << self
      
      @component = JFrame.new
      
      java_component.layout = layout if layout

      exit_on_close unless $is_java_applet or not Defaults.exit_on_frame_close
      
      #TODO is it possible to workaround at_exit?
      on_close do
        
        Swiby::RemoteLoader.cache_manager.close if Swiby::RemoteLoader.cache_manager
      
        @@frames.delete self
      
        exit if @component.default_close_operation == JFrame::EXIT_ON_CLOSE
      
      end
      
    end

    def dispose_on_close
      @component.setDefaultCloseOperation JFrame::DISPOSE_ON_CLOSE
    end

    def hide_on_close
      @component.setDefaultCloseOperation JFrame::HIDE_ON_CLOSE
    end

    def exit_on_close
      @component.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
    end
    
    def visible=(flag)
      
      super
      
      if flag
        
        @@frames << self
        
        do_apply_styles
        
      else
        @@frames.delete self
      end
          
      if flag and @width.nil? and @height.nil?
        @component.pack if Defaults.auto_sizing_frame
      end
      
    end

    def close
      
      @@frames.delete self
      
      @on_close_block.call if @on_close_block
      
      @component.dispose
      
      exit if @component.default_close_operation == JFrame::EXIT_ON_CLOSE
      
    end
    
    def java_container
      @component.content_pane
    end
    
    def swing &block
      
      component = @last_added.java_component(true) if @last_added
      component = self.java_component unless component
      
      block.call(component)

    end

    def content= child
      add child
    end
    
    def add(child, layout_hint = nil)
      
      @last_added = child
      
      if layout_hint
        @component.content_pane.add child.java_component, layout_hint
      else
        @component.content_pane.add child.java_component
      end
      
    end
    
    def on_close &block

      listener = WindowCloseListener.new

      @component.addWindowListener(listener)

      listener.register(&block)
      
      @on_close_block = block unless @on_close_block

    end
    
    def toolbar &block

      if @tb_container.nil?
        @tb_container = JPanel.new(AWT::FlowLayout.new(AWT::FlowLayout::LEFT))
        @component.content_pane.add @tb_container, AWT::BorderLayout::NORTH
      end

      tb = Toolbar.new
      
      local_context = self.context() #TODO pattern repeated at several places!

      tb.instance_eval do

        @local_context = local_context

        def context()
          @local_context
        end

      end

      tb.instance_eval(&block)

      @tb_container.add tb.java_component

    end

    def menus=(array)
      addMenus array
    end

    def menus(&array)
      addMenus array.call
    end

    def title=(t)
      @component.title = t
    end

    def title
      @component.title
    end

    def title(x)

      if x.instance_of? IncrementalValue
        x.assign_to self, :title=
      else
        self.title = x
      end

    end

    def add_child child
      
      @children = [] unless @children
      
      @children << child
      
    end
    
    def apply_styles
      do_apply_styles
    end
    
    def do_apply_styles
    
      return unless @styles

      style_resolver = @styles.resolver

      color = style_resolver.find_background_color(:container)
      @component.content_pane.background = color if color
      @component.background = color if color

      if @children
        @children.each do |kid|
          kid.apply_styles @styles
        end
      end
      
    end
    
    protected
  
    def content_done
      @last_added = nil
    end

    private

    def apply_styles_to_all
      
      @@frames.each do |frame|
        frame.do_apply_styles
      end
      
    end
    
    def addMenus(array)

      if @menu_bar.nil?

        @menu_bar = JMenuBar.new

        @component.jmenu_bar = @menu_bar

      end

      if array.respond_to? :each

        array.each do |comp|
          @menu_bar.add comp.java_component
        end

      else
        @menu_bar.add array.java_component
      end

    end

  end
  
end