#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/swing/base'
require 'swiby/swing/event'
require 'swiby/builder'
require 'swiby/style_resolver'
require 'swiby/layout_factory'

require 'swiby/util/extension_loader'

require 'java'
require 'erb'

module Swiby

  include_class 'java.lang.System'

  include_class ['HTMLEditorKit', 'StyleSheet'].map {|e| "javax.swing.text.html." + e}
  include_class [
    'Box',
    'ButtonGroup',
    'DefaultListModel',
    'ImageIcon',
    'JApplet',
    'JButton',
    'JCheckBox',
    'JComboBox',
    'JDialog',
    'JFormattedTextField',
    'JFrame',
    'JEditorPane',
    'JLabel',
    'JList',
    'JMenu',
    'JMenuBar',
    'JMenuItem',
    'JOptionPane',
    'JPanel',
    'JRadioButton',
    'JTabbedPane',
    'JTextField',
    'JToolBar',
    'KeyStroke',
    'UIManager',
    'SwingConstants'
  ].map {|e| "javax.swing." + e}

  module AWT
    include_class 'java.awt.Color'
    include_class 'java.awt.Dimension'
    include_class 'java.awt.GridLayout'
    include_class 'java.awt.BorderLayout'
    include_class 'java.awt.event.InputEvent'
  end

  module Border
    include_class 'javax.swing.border.EmptyBorder'
  end
  
  include_class 'java.util.Locale'
  include_class 'java.text.NumberFormat'
  include_class 'java.text.SimpleDateFormat'
  include_class 'javax.swing.text.MaskFormatter'
  include_class 'javax.swing.text.DateFormatter'
  include_class 'javax.swing.text.NumberFormatter'
  include_class 'javax.swing.text.DefaultFormatterFactory'

  ALT = AWT::InputEvent::ALT_MASK
  CTL = AWT::KeyEvent::CTRL_DOWN_MASK

  Q = AWT::KeyEvent::VK_Q
  X = AWT::KeyEvent::VK_X
  F4 = AWT::KeyEvent::VK_F4

  CENTER = SwingConstants::CENTER
  LEADING = SwingConstants::LEADING
  TOP = SwingConstants::TOP
  LEFT = SwingConstants::LEFT
  RIGHT = SwingConstants::RIGHT
  BOTTOM = SwingConstants::BOTTOM
  TRAILING = SwingConstants::TRAILING

  WRAP = JTabbedPane::WRAP_TAB_LAYOUT
  SCROLL = JTabbedPane::SCROLL_TAB_LAYOUT

  UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()) unless System::get_property('swing.defaultlaf')

  module ComponentExtension
    VERSION = 1.0
    CATEGORY = 'component'
    AUTHOR = 'Jean Lazarou'  
  end
  
  class SwibyRunnable
    
    attr_reader :result, :error
    
    include java.lang.Runnable
  
    def initialize &todo
      @todo = todo
      @error = nil
    end
    
    def failed?
      not @error.nil?
    end
    
    def run
      begin
        @result = @todo.call
      rescue Exception => err
        @error = err
      end
    end
    
  end
  
  def sync_swing_thread &block
    
    if AWT::EventQueue.isDispatchThread
      block.call
    else
      
      runnable = SwibyRunnable.new(&block)

      AWT::EventQueue.invokeAndWait(runnable)

      raise runnable.error if runnable.failed?
      
      runnable.result
      
    end
    
  end
  
  class Defaults
  
    @@auto_sizing_frame = false
    def self.auto_sizing_frame
       @@auto_sizing_frame
    end
    def self.auto_sizing_frame= flag
       @@auto_sizing_frame = flag
    end
    
    @@exit_on_frame_close = true    
    def self.exit_on_frame_close
      @@exit_on_frame_close
    end
    def self.exit_on_frame_close= flag
      @@exit_on_frame_close = flag
    end
  
    @@width = 0
    def self.width
       @@width
    end
    def self.width width
       @@width = width
    end
  
    @@height = 0
    def self.height
       @@height
    end
    def self.height= height
       @@height = height
    end
    
    @@enhanced_styling = false
    def self.enhanced_styling?
       @@enhanced_styling
    end
    def self.enhanced_styling= flag
       @@enhanced_styling = flag
    end
        
  end
  
  module ComponentAccesssor

    def [] index

      if index.instance_of?(Fixnum)
        @kids[index]
      else
        @kids_by_name[index.to_s]
      end
      
    end
    
    def []= key, value
      @kids_by_name[key.to_s] = value
    end
    
    # The component is registered but not added to the Swing structure
    def << component
      @kids << component
    end
    
    def each type = nil, &block
      
      if type.nil?
        
        @kids.each(&block)
        
      else
        
        @kids.each do |x|
          yield(x) if x.kind_of?(type)
        end
        
      end
      
    end
    
    def select condition = nil, &block
      
      if condition.nil?
        
        @kids.select(&block)
        
      else
        
        @kids.select do |x|
          
          if x.respond_to?(:text)
            x.text == condition
          else
            x.value == condition
          end

        end
        
      end
      
    end

  end
  
  class Container < SwingBase

    include Builder
    include ComponentAccesssor

    def initialize *args
      @kids = []
      @kids_by_name = {}
    end
    
    def content(*options, &block)
    
      layout = create_layout(*options)
      @component.layout = layout if layout

      if layout.respond_to?(:add_layout_extensions)
        layout.add_layout_extensions self
      end
      
      self.instance_eval(&block)
      
    end
    
    def height=(h)
      @height = h
    end

    def height
      @height
    end

    def height(h)
      self.height = h
    end

    def visible=(flag)

      if !@component.visible and (@width or @height)
        
        @width = Defaults.width unless @width
        @height = Defaults.height unless @height
        
        @component.set_size @width, @height
        
      end
      
      @component.visible = flag

      @component.validate

    end

    def dimension

      if @width
        w = @width
      else
        w = @component.getWidth
      end

      if @height
        h = @height
      else
        h = @component.getHeight
      end

      return w, h

    end

    def visible
      @component.visible
    end

    def visible(flag)
      self.visible = flag
    end

    def width=(w)
      @width = w
    end

    def width
      @width
    end

    def width(w)
      self.width = w
    end

    def message_box text
      JOptionPane.showMessageDialog @component, text
    end

  end

  def bind(model = nil, getter = nil, &block)

    if model.nil?
      IncrementalValue.new(block)
    else
      IncrementalValue.new(model, getter, block)
    end

  end
  
end
