#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/swing'
require 'swiby/layout/border'
require 'swiby/component/layer'
require 'swiby/component/panel'
require 'swiby/component/toolbar'

import javax.swing.JDialog
import javax.swing.JFrame

module Swiby
  
  def window *args, &block
    frame(*args, &block)
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
  
  class LayerContainer < javax.swing.JLayeredPane
    
    attr_reader :default_layer_panel

    def do_initialize parent, layout
      
      @default_layer_panel = Panel.new
      
      @default_layer = @default_layer_panel.java_component
      @default_layer.layout = layout
        
      add @default_layer
      set_layer @default_layer, javax.swing.JLayeredPane::DEFAULT_LAYER
        
      listener = ResizeListener.new
      
      listener.register do |ev|
        
        popup = parent.layers[:popup]
        
        if popup
          
          popup = popup.java_component
          
          rc = ev.getComponent.getBounds
          dim = popup.getPreferredSize

          popup.setBounds(rc.x + (rc.width - dim.width) / 2, rc.y + (rc.height - dim.height) / 2, dim.width, dim.height)
          
        end

        parent.layers.each do |name, layer|
          
          rc = ev.getComponent.getBounds

          unless name == :popup
            pane = layer.java_component            
            pane.setBounds(rc.x, rc.y, rc.width, rc.height)
          end
          
        end
        
      end
      
      self.addComponentListener listener
      
    end
    
    def doLayout
      @default_layer.setBounds(0, 0, getWidth(), getHeight())
    end
    
  end

  class Frame < Container

    @@frames = []

    attr_reader :default_layer, :layers
    
    def initialize layout = nil, as_dialog = false, parent = nil

      super
      
      layout = BorderLayout.new unless layout
      
      layered_pane = LayerContainer.new
      layered_pane.do_initialize self, layout
      @default_layer = layered_pane.default_layer_panel.java_component
      
      @layers = {}
      @layers[:default] = layered_pane.default_layer_panel
      
      if as_dialog
        
        @parent = parent
        
        @component = JDialog.new(parent ? parent.java_component : nil)
        @component.modal = true
        
        @component.layered_pane = layered_pane
        
        def self.java_container
          @component
        end

        def self.visible= flag

          if flag
            apply_styles
          end
          
          preferred = @default_layer.preferred_size
          
          if @width and @width > 0
            preferred.width = @width
          end
          
          if @height and @height > 0
            preferred.height = @height
          end
          
          insets = @component.insets
          preferred.width += insets.left + insets.right
          preferred.height += insets.top + insets.bottom
          
          @component.set_minimum_size(preferred)
          
          if !@component.visible and @width and @height
            @component.set_size @width, @height
          else
            @component.content_pane.set_preferred_size preferred
            @component.pack
          end

          if @parent
            w = @component.width
            h = @component.height
            
            x = (@parent.java_component.width - w) / 2 if @parent.java_component.width > w
            y = (@parent.java_component.height - h) / 2 if @parent.java_component.height > h

            @component.setBounds x, y, w, h if x and y
          end
          
          unless @component.visible or x or y
            if @autosize_enabled or (@autosize_enabled.nil? and Defaults.auto_sizing_frame)
        
              insets = @component.insets
              preferred.width += insets.left + insets.right
              preferred.height += insets.top + insets.bottom
              
              @component.content_pane.set_preferred_size preferred
              @component.pack
              
            end
         end
          
          @component.visible = flag
          
        end

        return
        
      end
      
      @@frames << self
      
      @component = JFrame.new      
      @component.layered_pane = layered_pane

      exit_on_close unless $is_java_applet or not Defaults.exit_on_frame_close
      
      #TODO is it possible to workaround at_exit?
      on_close do
        
        Swiby::RemoteLoader.cache_manager.close if Swiby::RemoteLoader.cache_manager
      
        @@frames.delete self
      
      end
      
    end

    def autosize enable_autosize = true
      @autosize_enabled = enable_autosize
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
    
    def layout_manager= layout
      @default_layer.layout = layout
    end
    
    def visible=(flag)

      super
      
      if flag
        
        @@frames << self
        
        do_apply_styles
        
      else
        @@frames.delete self
      end
          
      if flag
          
        preferred = @default_layer.preferred_size
        
        if @width and @width > 0
          preferred.width = @width
        end
        
        if @height and @height > 0
          preferred.height = @height
        end
        
        insets = @component.insets
        preferred.width += insets.left + insets.right
        preferred.height += insets.top + insets.bottom
        
        @component.set_minimum_size(preferred)
        
        if @autosize_enabled or (@autosize_enabled.nil? and Defaults.auto_sizing_frame)
          
          @component.set_preferred_size preferred
          @component.pack
        
        end
      
      end
      
    end

    def close
      
      @@frames.delete self
      
      window_listener_class = java.lang.Class.forName("java.awt.event.WindowListener")

      event = java.awt.event.WindowEvent.new(@component,  java.awt.event.WindowEvent::WINDOW_CLOSING)
      
      @component.getListeners(window_listener_class).each do |listener|
        listener.windowClosing event
      end
      
      @component.dispose
      
      exit if @component.default_close_operation == JFrame::EXIT_ON_CLOSE
      
    end
    
    def java_container
      @component.content_pane
    end
    
    def content= child
      add child
    end
    
    def add(child, layout_hint = nil)
      
      @last_added = child
      
      if layout_hint
        @default_layer.add child.java_component, layout_hint
      else
        @default_layer.add child.java_component
      end
      
    end
    
    def on_close &block

      listener = WindowCloseListener.new
      
      @component.addWindowListener(listener)

      listener.register(&block)
 
    end
    
    def toolbar &block

      if @tb_container.nil?
        @tb_container = JPanel.new(FlowLayout.new(FlowLayout::LEFT))
        @default_layer.add @tb_container, BorderLayout::NORTH
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
      @default_layer.background = color if color

      if @children
        @children.each do |kid|
          kid.apply_styles @styles
        end
      end
      
      @layers.each do |name, layer|
        layer.apply_styles @styles
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
