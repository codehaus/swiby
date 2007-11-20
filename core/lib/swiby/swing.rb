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

require 'java'
require 'erb'

module Swiby

  include_class 'java.lang.System'

  include_class ['HTMLEditorKit', 'StyleSheet'].map {|e| "javax.swing.text.html." + e}
  include_class [
    'Box',
    'DefaultListModel',
    'ImageIcon',
    'JApplet',
    'JButton',
    'JComboBox',
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
  
  #TODO move to swing directory?
  module Swing
    
    include_class 'javax.swing.plaf.basic.BasicComboBoxRenderer'
    
    class SwibyComboBoxRender < BasicComboBoxRenderer
      
      def getListCellRendererComponent list, value, index, is_selected, has_focus
        
        if value.respond_to?(:display_icon)
          set_icon value.display_icon
        end

        value = to_human_readable(value)

        super
        
      end
      
    end
    
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
    
    def content(&block)
      block.call
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

      @component.visible = flag
      @component.pack

      #if @width or @height

      w, h = dimension

      @component.setSize w, h
      @component.pack
      @component.validate

      w, h = dimension

      @component.setSize w, h

      #end

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

  class Panel < Container

    def initialize
      super
      @component = JPanel.new
    end

    def add(child)
      @component.add child.java_component
    end

  end

  class Frame < Container

    def initialize layout = nil

      super
      
      @component = JFrame.new

      @component.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE unless $is_java_applet

      if layout
        
        layout = create_layout(layout)
        
        @component.content_pane.layout = layout if layout
        
      end
      
      #TODO is it possible to workaround at_exit?
      on_close do
        Swiby::RemoteLoader.cache_manager.close if Swiby::RemoteLoader.cache_manager
      end
      
    end

    def dispose_on_close
      @component.setDefaultCloseOperation JFrame::DISPOSE_ON_CLOSE
    end

    def hide_on_close
      @component.setDefaultCloseOperation JFrame::HIDE_ON_CLOSE
    end

    def close
      
      @on_close_block.call if @on_close_block
      
      @component.dispose
      
      exit if @component.default_close_operation == JFrame::EXIT_ON_CLOSE
      
    end
    
    def content= child
      add child
    end
    
    def add(child)
      @component.content_pane.add child.java_component
    end

    def on_close &block

      listener = WindowCloseListener.new

      @component.addWindowListener(listener)

      listener.register(&block)
      
      @on_close_block = block

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

    private

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

  class Applet < Frame

    def initialize

      if $parent_applet.nil?

        @parent_frame = JFrame.new

        @component = JApplet.new

        @parent_frame.content_pane.add @component, CENTER

        @parent_frame.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE

      else

        @component = $parent_applet

      end

      def @component.pack
        @parent_frame.pack unless @parent_frame.nil?
      end

    end

    def title= t
    end

    def visible=(flag)

      if @parent_frame.nil?
        @component.validate
        return
      end

      @parent_frame.visible = flag
      @parent_frame.pack

      w, h = dimension

      @parent_frame.setSize w, h
      @parent_frame.pack
      @parent_frame.validate

      w, h = dimension

      @parent_frame.setSize w, h

      @parent_frame.validate

    end

  end

  class Section < SwingBase
    
    def initialize title

      @component = JPanel.new
      @component.border = Swing::BorderFactory.createTitledBorder(title) unless title.nil?

    end
    
    def layout= layout_manager
      @component.layout = layout_manager
    end
    
    def add child
      @component.add child.java_component
    end
    
    def text
      @component.border.title unless @component.border.nil?
    end
    
    def text= t
      @component.border.title = t
    end
    
  end
  
  class Label < SwingBase

    swing_attr_accessor :text

    def initialize

      @component = JEditorPane.new

      @component.editable = false
      @component.content_type = 'text/html'

      @component.background = AWT::Color.new(236, 233, 216) #TODO use JLabel bg color...

      kit = HTMLEditorKit.new
      styles = StyleSheet.new

      #TODO use JLabel default font
      styles.addRule 'body,h1,h2,h3,h4,h5 { font-family:arial; }'
      styles.addRule 'body { font-size:11pt; }'
      styles.addRule 'h1 { font-size:16pt; font-weight: bold }'
      styles.addRule 'h2 { font-size:14pt; font-weight: bold }'
      styles.addRule 'h3 { font-size:12pt; font-weight: bold }'
      styles.addRule 'h4 { font-size:10pt; font-weight: bold }'
      styles.addRule 'h5 { font-size:10pt; font-weight: italic }'
      styles.addRule 'a { color: blue; text-decoration: underline }'

      kit.style_sheet = styles

      @component.editor_kit = kit

    end

    def css_rules(&block)
      yield @component.editor_kit.style_sheet
    end

    def html(x = nil, &block)

      if x.instance_of? IncrementalValue

        block = x.block

        theBinding = block.binding

        x.replaceBlock {
          html = ERB.new(block.call)
          html.result
        }

        listener = HyperlinkListener.new

        listener.register do |script|
          eval script, theBinding
        end

        @component.addHyperlinkListener listener

        x.assign_to self, :text=

      else

        if x.nil?
          x = block.call
        end

        html = ERB.new(x)

        self.text = html.result

      end

    end

  end

  class SimpleLabel < SwingBase

    def initialize options = nil
      
      @component = JLabel.new
      
      return unless options

      if options[:label]
        
        x = options[:label] 
        
        if x.instance_of? IncrementalValue
          x.assign_to self, :text=
        else
          self.text = x
        end
        
      end

      self.linked_field = options[:input_component] if options[:input_component]
      self.name = options[:name].to_s if options[:input_component].nil? && options[:name]
      
    end

    def apply_styles
      
      font = StyleResolver.font(:label)
      @component.font = font if font
      
      color = StyleResolver.color(:label)
      @component.foreground = color if color
      
    end
    
    def linked_field=(comp)
      comp.linked_label = self
      @linked_field = comp
      @component.set_label_for(comp.java_component)
    end
    
    def linked_field
      @linked_field
    end

    def text=(t)

      #TODO is here the right place for this decision? (using IncrementalValue, raw value or HTML)
      if t.instance_of? IncrementalValue
        t.assign_to self, :text=
      elsif t.instance_of? String
        t = ERB.new(t).result #TODO use if HTML not only in Label + maybe ERB is too much if simple string?
      end
      
      @component.text = t
      
    end

    def text
      @component.text
    end

  end

  class TextField < SwingBase

    attr_accessor :linked_label
    swing_attr_accessor :columns, :editable

    def initialize options = nil
      
      @component = JFormattedTextField.new
      
      return unless options
      
      options[:input_component] = self
      
      x = options[:text]
      
      if x.instance_of? IncrementalValue
        x.assign_to self, :value=
      else
        self.value = x if x
      end
      
      self.name = options[:name].to_s if options[:name]
      self.editable = !options[:readonly] if options[:readonly]
      
    end

    def apply_styles
      
      font = StyleResolver.font(:input)
      @component.font = font if font
      
      color = StyleResolver.color(:input)
      @component.foreground = color if color
      
      color = StyleResolver.background_color(:input)
      @component.background = color if color
      
    end

    def editable?
      editable
    end
    
    def install_listener iv

      ea = EnterAction.new

      ea.register do
        iv.change @component.text
      end

    end

    def on_change &block
            
      listener = PropertyChangeListener.new

      listener.register(&block)

      @component.addPropertyChangeListener('value', listener)
  
    end
    
    def value
      @component.value
    end

    def value=(val)
      
      plug_formatter_for val unless @formatter_set
      
      @component.value = val
      
    end
    
    def plug_formatter_for value

      if value.respond_to?(:plug_input_formatter)
        value.plug_input_formatter self
      end
      
      @formatter_set = true
      
    end

    def input_mask mask, placeholder = "_"
      
      formatter = MaskFormatter.new

      formatter.mask = mask

      formatter.placeholder_character = placeholder[0]
      formatter.value_contains_literal_characters = false

      self.formatter_factory = DefaultFormatterFactory.new(formatter)

    end
    
    def date mask = nil

      return unless mask
      
      fmt = DateFormatter.new(SimpleDateFormat.new(mask))

      self.formatter_factory = DefaultFormatterFactory.new(fmt)

    end
    
    def currency cur
      
      #TODO add support for country as string or symbol
      case cur
      when :euro
        locale = Locale::FRANCE
      when :dollar
        locale = Locale::US
      end

      fmt = NumberFormat::getCurrencyInstance(locale)

      self.formatter_factory = DefaultFormatterFactory.new(NumberFormatter.new(fmt))

      @component.horizontal_alignment = JTextField::RIGHT
        
    end
    
    def formatter_factory= factory
      @component.formatter_factory = factory
    end

  end

  class Button < SwingBase

    swing_attr_accessor :enabled, :editable
    swing_attr_accessor :text

    def initialize options = nil

      @component = JButton.new

      return unless options

      self.text = options[:text] if options[:text]
      self.enabled_state = options[:enabled] unless options[:enabled].nil?
      self.name = options[:name].to_s if options[:name]

      icon options[:icon] if options[:icon]
      action(&options[:action]) if options[:action]

    end

    def editable?
      editable
    end

    def enabled_state= value

      if value.instance_of? IncrementalValue
        value.assign_to self, :enabled=
      else
        self.enabled = value
      end

    end

    def icon(image)

      if not image.nil? and image.instance_of?(String)
        image = Swiby::create_icon(image)
      end

      @component.icon = image unless image.nil?

    end

    def mnemonic(char)
      @component.mnemonic = char[0]
    end

    def tooltip(text)
      @component.toolTipText = text
    end

    def action(&block)

      listener = ActionListener.new

      @component.addActionListener(listener)

      listener.register(&block)

    end

    def verticalTextPosition pos
      @component.verticalTextPosition = pos
    end

    def horizontalTextPosition pos
      @component.horizontalTextPosition = pos
    end

  end

  class ComboBox < SwingBase

    attr_accessor :linked_label
    swing_attr_accessor :editable, :selection => :selected_index

    def initialize options = nil
      
      @component = create_list_component
      
      @component.set_renderer Swing::SwibyComboBoxRender.new
      
      return unless options
      
      options[:input_component] = self
      
      values = options[:values]
      selected = options[:selected]

      if values.instance_of? IncrementalValue
        values = values.get_value
      end
      
      @values = values

      self.value = selected

      self.name = options[:name].to_s if options[:name]
      
      action(&options[:action]) if options[:action]
      
    end

    def editable?
      editable
    end
    
    def create_list_component
      JComboBox.new
    end

    def action(&block)

      listener = ActionListener.new

      @component.addActionListener(listener)

      listener.register do
        
        block.call(@values[@component.selected_index])
        
      end
      
    end
    
    def install_listener iv

      listener = ActionListener.new

      @component.addActionListener(listener)

      listener.register do
        iv.change @component.selected_index
      end

    end

    def selection=(index)
      @component.selected_index = index.to_i
    end
    
    def item_count
      @component.item_count
    end
    
    def value= x

      select_index = -1

      @values.each do |value|

        self.add_item value

        select_index = self.item_count - 1 if value == x

      end

      self.selection = select_index unless select_index == -1
      
    end
    
    def value
      
      index = selection
      
      @values[index] if index >= 0
      
    end
    
    protected
    
    def add_item value
      @component.add_item value
    end

  end

  class ListBox < ComboBox

    attr_accessor :linked_label
    
    def initialize options = nil

      super options
      
      scrollable

    end
    
    def create_list_component

      @model = DefaultListModel.new

      comp = JList.new
      comp.model = @model
      
      comp

    end

    def action(&block)

      listener = ListSelectionListener.new

      @component.addListSelectionListener(listener)

      listener.register do
        
        block.call(@values[@component.selected_index])
        
      end
      
    end

    def install_listener iv

      listener = ListSelectionListener.new

      @component.addListSelectionListener(listener)

      listener.register do
        iv.change @component.selected_index
      end

    end
    
    def item_count
      @model.size
    end
    
    def add_item value
      @model.addElement value
    end

  end

  class Editor < SwingBase
    
    def initialize options = nil

      @component = JEditorPane.new
            
      return unless options

      if options[:width] and options[:height]
        
        w = options[:width]
        h = options[:height]
        
        @component.preferred_size = AWT::Dimension.new(w, h)

        self.name = options[:name].to_s if options[:name]
        self.editable = !options[:readonly] if options[:readonly]

      end
      
      scrollable

    end
    
    def apply_styles
      
      font = StyleResolver.font(:editor)
      @component.font = font if font
      
      color = StyleResolver.color(:editor)
      @component.foreground = color if color
      
    end
    
    def text
      @component.text
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

    def on_change &block
            
      listener = DocumentListener.new

      listener.register(&block)

      @component.document.addDocumentListener(listener)
  
    end
    
  end
  
  class ButtonOptions < ComponentOptions
    
    define "Button" do
      
      declare :name, [String, Symbol], true
      declare :text, [String, Symbol], true
      declare :icon, [ImageIcon, String], true
      declare :action, [Proc], true
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      
      overload :text
      overload :icon
      overload :text, :icon
      overload :text, :icon, :enabled
      
    end
    
  end

  class LabelOptions < ComponentOptions
      
    define "Label" do
      
      declare :name, [String, Symbol], true
      declare :label, [String, Symbol, IncrementalValue]
      
      overload :label

    end
    
  end
  
  class InputOptions < ComponentOptions
    
    define "Input" do
      
      declare :name, [String, Symbol], true
      declare :label, [String, Symbol], true
      declare :text, [Object]
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      declare :readonly, [TrueClass, FalseClass, IncrementalValue], true
      declare :input_component, [Object], true
      
      overload :text
      overload :label, :text
      
    end
    
  end
  
  class EditorOptions < ComponentOptions
    
    define "Editor" do
      
      declare :name, [String, Symbol], true
      declare :width, [Integer], true
      declare :height, [Integer], true
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      declare :readonly, [TrueClass, FalseClass, IncrementalValue], true
      
      overload :width, :height
      
    end
    
  end

  class ListOptions < ComponentOptions
    
    define "List" do
      
      declare :name, [String, Symbol], true
      declare :label, [String, Symbol], true
      declare :values, [Array, AccessorPath]
      declare :selected, [Object], true
      declare :action, [Proc], true
      declare :enabled, [TrueClass, FalseClass, IncrementalValue], true
      declare :input_component, [Object], true
      
      overload :values
      overload :label, :values
      overload :label, :values, :selected
      
    end

  end

  class Toolbar < SwingBase

    def initialize
      @component = JToolBar.new
    end

    def add child
      @component.add child.java_component
    end

    include Builder

  end

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

  class TabbedPane < SwingBase

    container :tabs

    swing_attr_writer :tabPlacement, :selectedIndex, :tabLayout => :tabLayoutPolicy

    def initialize
      @component = JTabbedPane.new
    end

    def addComponents(array)

      @component.remove_all

      if array.is_a? IncrementalValue

        array.assign_to self, :addComponents

        return

      end

      if array.respond_to? :each

        array.each do |comp|
          @component.addTab comp.title, nil, comp.java_component, comp.tooltip
        end

      else
        @component.addTab array.title, nil, array.java_component, array.tooltip
      end

    end

  end

  class Tab < SwingBase

    def title=(t)
      @title = t
    end

    def title(t = nil)
      return @title if t.nil?
      self.title = t
    end

    def tooltip=(t)
      @tooltip = t
    end

    def tooltip(t = nil)
      return @tooltip if t.nil?
      self.tooltip = t
    end

    def initialize
      @component = JPanel.new
    end

  end

  class Accelerator

    def modifier mod
      @modifier = mod
    end

    def key_stroke key
      @key_stroke = key
    end

    def java_accelerator
      KeyStroke.getKeyStroke(@key_stroke, @modifier)
    end

  end

  class GridPanel < SwingBase

    container :cells

    def initialize

      @layout = AWT::GridLayout.new

      @component = JPanel.new
      @component.layout = @layout

    end

    def content(&block)
      self.content = block.call
    end

    def content=(child)
      @component.content_pane.add child.java_component
    end

    def border=(b)
      @component.border = b.java_border
    end

    def border(b = nil, &block)

      if b.nil?
        border = block.call
      else
        border = b
      end

      @component.border = border.java_border

    end

    def rows(n)
      @layout.rows = n
    end

    def columns(n)
      @layout.columns = n
    end

    def vgap(gap)
      @layout.vgap = gap
    end

    def hgap(gap)
      @layout.hgap = gap
    end

  end

  class FlowPanel < SwingBase

    container :content

    def initialize

      @layout = AWT::FlowLayout.new

      @component = JPanel.new
      @component.layout = @layout

    end

    def border=(b)
      @component.border = b.java_border
    end

    def border(b = nil, &block)

      if b.nil?
        border = block.call
      else
        border = b
      end

      @component.border = border.java_border

    end

    def vgap(gap)
      @layout.vgap = gap
    end

  end

  class BorderPanel < SwingBase

    def initialize

      @layout = AWT::BorderLayout.new

      @component = JPanel.new
      @component.layout = @layout

    end

    def top panel
      @component.add panel, AWT::BorderLayout::NORTH
    end

    def left panel
      @component.add panel.java_component, AWT::BorderLayout::WEST
    end

    def center panel
      @component.add panel.java_component, AWT::BorderLayout::CENTER
    end

    def right panel
      @component.add panel.java_component, AWT::BorderLayout::EAST
    end

    def bottom panel
      @component.add panel.java_component, AWT::BorderLayout::SOUTH
    end

  end

  class RigidArea

    def height h
      @height = h
    end

    def width w
      @width = w
    end

    def java_component

      if @component.nil?

        raise RuntimeError, "@width and @height cannot be both nil" if @width.nil? and @height.nil?

        if @width.nil?
          @component = Box.createHorizontalStrut(@height)
        elsif @height.nil?
          @component = Box.createVerticalStrut(@width)
        else
          @component = Box.createRigidArea(AWT::Dimension.new(@width, @height))
        end

      end

      @component

    end

  end

  class EmptyBorder

    def top(top)
      @top = top
    end

    def left(left)
      @left = left
    end

    def bottom(bottom)
      @bottom = bottom
    end

    def right(right)
      @right = right
    end

    def java_border()

      @border = Border::EmptyBorder.new(@top, @left, @bottom, @right) unless @border

      @border

    end

  end
  
  def frame layout = nil, &block

    x = layout ? ::Frame.new(layout) : ::Frame.new

    def x.context()
      self
    end
    
    x.instance_eval(&block) unless block.nil?

    x

  end

  def bind(model = nil, getter = nil, &block)

    if model.nil?
      IncrementalValue.new(block)
    else
      IncrementalValue.new(model, getter, block)
    end

  end

end