#--
# BSD license
# 
# Copyright (c) 2007, Jean Lazarou
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice, this list 
# of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this 
# list of conditions and the following disclaimer in the documentation and/or other
# materials provided with the distribution. 
# Neither the name of the null nor the names of its contributors may be 
# used to endorse or promote products derived from this software without specific 
# prior written permission. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
# OF THE POSSIBILITY OF SUCH DAMAGE.
#++

require 'swiby_core'
require 'java'
require 'erb'

module F3

	include_class ['HTMLEditorKit', 'StyleSheet'].map {|e| "javax.swing.text.html." + e}
	include_class [
			'Box',
			'DefaultListModel',
			'ImageIcon',
			'JButton',
			'JComboBox',
			'JFrame',
			'JEditorPane',
			'JLabel',
			'JList',
			'JMenu',
			'JMenuBar',
			'JMenuItem',
			'JPanel',
			'JTabbedPane',
			'JTextField',
			'KeyStroke',
			'UIManager',
			'SwingConstants'
	].map {|e| "javax.swing." + e}
    
	module Swing
	  include_class 'javax.swing.event.HyperlinkEvent'
	  include_class 'javax.swing.event.HyperlinkListener'
	  include_class 'javax.swing.event.ListSelectionListener'
	end
    
	module AWT
    include_class 'java.awt.Color'
		include_class 'java.awt.Toolkit'
		include_class 'java.awt.AWTEvent'
		include_class 'java.awt.Dimension'
		include_class 'java.awt.GridLayout'
		include_class 'java.awt.FlowLayout'
		include_class 'java.awt.BorderLayout'
		include_class 'java.awt.event.KeyEvent'
		include_class 'java.awt.event.InputEvent'
		include_class 'java.awt.event.ActionListener'
		include_class 'java.awt.event.AWTEventListener'
	end

	module Border
		include_class 'javax.swing.border.EmptyBorder'
	end
    
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
	
	UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName())
	
	class Frame < SwingBase
		
		def initialize
		
			@component = JFrame.new
			
			@component.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE unless $is_java_applet
			
		end
	
		def content(&block)
			self.content = block.call
		end
	
		def dispose_on_close
			@component.setDefaultCloseOperation JFrame::DISPOSE_ON_CLOSE
		end
		
		def hide_on_close
			@component.setDefaultCloseOperation JFrame::HIDE_ON_CLOSE
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
		
		def content=(child)
			@component.content_pane.add child.java_component
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
				
				@component = javax.swing.JApplet.new
				
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
		
		def initialize
			@component = JLabel.new
		end
	
		def text=(t)
			@component.text = t
		end
		
		def text
			@component.text
		end
	
		def text(x)
			
			if x.instance_of? IncrementalValue
				x.assign_to self, :text=
			elsif x.instance_of? String
				self.text = ERB.new(x).result #TODO use if HTML not only in Label + maybe ERB is too much if simple string?
			else
				self.text = x
			end
			
		end
		
	end
	
	class TextField < SwingBase
		
		swing_attr_accessor :value => :text
		swing_attr_accessor :columns
		
		def initialize
			@component = JTextField.new
		end
	
		def install_listener iv

			ea = EnterAction.new
			
			ea.register do
				iv.change @component.text
			end
			
		end
		
		def value=(t)
			@component.text = t.to_s
		end
		
	end

	def createImageIcon(url)
        
		#TODO add cache, loading from JAR...
		java.net.URL imgURL = java.net.URL.new(url)
        
		if imgURL.nil?
            #TODO handle the error?
			puts "Couldn't find file: " + url
            nil
        else
            ImageIcon.new(imgURL)
        end
		
 	end
	
	class Button < SwingBase
		
		swing_attr_accessor :enabled
		swing_attr_accessor :text
		
		def initialize
			@component = JButton.new
		end
	
		def icon(url)
			
			image = createImageIcon(url)
			
			@component.icon = image if not image.nil?
			
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
			
			listener.register &block
		
		end
		
		def verticalTextPosition pos
			@component.verticalTextPosition = pos
		end
		
		def horizontalTextPosition pos
			@component.horizontalTextPosition = pos
		end
		
	end
	
	class ComboBox < SwingBase
	
		container :cells
		swing_attr_accessor :selection => :selected_index
	
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
		
		def initialize
			@component = JComboBox.new
		end

		#TODO ListBox has similar addComponents method, diff is addItem replace by model.addElement
		#     should use same approach, replacing DefaultListModel with javax.swing.DefaultComboBoxModel
		#TODO is addComponents the right name to add items to a list/combobox? => the name is set by the 'container' method
		def addComponents components
		
			if components.is_a? IncrementalValue
				components = components.get_value self
			end
		
			components.each do |x|
				@component.addItem x
			end
		
		end
		
	end
	
	class ListBox < ComboBox
	
		def install_listener iv

			listener = ListSelectionListener.new
			
			@component.addListSelectionListener(listener)

			listener.register do
				iv.change @component.selected_index
			end
			
		end
		
		def initialize
		
			@model = DefaultListModel.new
		
			@component = JList.new
			@component.model = @model
			
			scrollable
			
		end
		
		def addComponents components
		
			if components.is_a? IncrementalValue
			
				components.validate_as_field_binding
				
				array = components.get_value
				
				add_array_observers array, self
				
				components = array
				
			end
			
			components.each do |x|
				@model.addElement x
			end
		
		end
		
		def delete_at index
			@model.removeElementAt index
		end
		
		def push value
			@model.addElement value
		end
		
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
			
			listener.register &block
		
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
	
	component_factory :Frame
	component_factory :Applet
	component_factory :GridPanel
	component_factory :FlowPanel
	component_factory :Empty => :EmptyBorder
	component_factory :Label
	component_factory :SimpleLabel
	component_factory :TextField
	component_factory :Button
	component_factory :ListBox
	component_factory :ComboBox
	component_factory :Menu
	component_factory :MenuItem
	component_factory :TabbedPane
	component_factory :Tab
	component_factory :BorderPanel
	component_factory :RigidArea

	def bind(model = nil, getter = nil, &block)
		
		if model.nil?
			IncrementalValue.new(block)
		else
			IncrementalValue.new(model, getter)
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
	
	class IncrementalValue
	
		IGNORE = %w[Array Bignum Comparable Config Class Dir Enumerable ENV ERB F3 Fixnum Float Hash
					IO Integer Kernel OptionParser Module Object Range Regexp String
					Time].map{|x| Regexp.new(x)} + [/REXML::/]
		
		def initialize(model, getter = nil, setter = nil)
		
			if model.instance_of? Proc
				@block = model
			else
			
				@model = model
				@getter = getter
				
				if setter.nil?
					@setter = "#{getter}=".to_sym
				else
					@setter = setter
				end
				
				add_setter_observer_to @model, @setter.to_s
				
			end
			
		end
		
		def validate_as_field_binding
			raise "Bound value cannot be a block" if not @block.nil?
		end
		
		def get_value
		
			if @block
			
				capture
				res = @block.call
				set_trace_func nil
				
			else
				res = @model.send @getter
			end
				
			res
			
		end
		
		def assign_to target, setter

			res = get_value
				
			@target = target
			@target_setter = setter
			
			@target.send @target_setter, res
			
		end
	
		def block
			@block
		end
		
		def replaceBlock(&b)
			@block = b
		end
		
		def change new_value
		
			if @model
				@model.send @setter, new_value
			end
			
		end
		
		def changed
			
			return if @target.nil?

			if @block
				new_value = @block.call
			else
				new_value = @model.send @getter
			end
			
			@target.send @target_setter, new_value
			
		end
		
		private
		
		def capture
	
			set_trace_func lambda { |event, file, line, id, binding, classname|
			
			   case event
				  when 'call', 'c-call'
					 if not IGNORE.any?{|re| re =~ classname.to_s }
						
						binding = eval("self", binding)
						
						instance_var = '@' + id.to_s
						
						if binding.instance_variables.include?(instance_var) and binding.send(id).is_a? Array
						 	#TODO also observe ([], last, first, ...)
							#puts "add_observer: #{binding}.#{id} => delete_at"
							#add_modifier_observer_to binding.send(id), "delete_at"
						end

					 	if binding.respond_to? "#{id}="
							puts "add_observer: #{binding} => #{id}"
							add_setter_observer_to binding, "#{id}="
						end
					 end
			   end
			
			}
			
		end
		
		def add_setter_observer_to obj, setter

			#TODO must check if getter and setter (instance_variable_defined?(:@x))
			
			observersSym = "observers_#{setter}"[0...-1].to_sym
			real_setter = "real_setter_#{setter}"[0...-1]
			
			add_observer_to obj, setter, observersSym, real_setter
			
		end
		
		def add_observer_to obj, method, observersSym, alias_name
			
			if obj.respond_to? observersSym
				observers = obj.send(observersSym)
				observers << self if not observers.include? self
				return
			end

			#TODO remove observers
			
			eval %{
				
				class << obj
				
					alias_method :#{alias_name}, :#{method}
				
					def #{observersSym}
					
						@#{observersSym} = [] if @#{observersSym}.nil?
					
						@#{observersSym}
						
					end
					
					def #{method}(value)
					
						#{alias_name} value
						
						if @#{observersSym}
							@#{observersSym}.each do |observer|
								observer.changed
							end
						end
						
					end
				
				end
				
			}
		
			obj.send(observersSym) << self
			
		end
		
	end

	def add_array_observers array, observer
		#TODO also observe (delete, delete_at, delete_if, <<, []=, push, pop, insert, shift, replace, uniq!, sort!, compact!, collect!)
		#     << and []= cannot be used as is to build the observers collection name and alias name
		#     how to limit them? so much method changes the array object

		[:delete_at, :push].each do |method|

			observersSym = "array_observers_#{method}".to_sym
			alias_name = "real_#{method}"
			
			if array.respond_to? observersSym
				observers = array.send(observersSym)
				observers << observer if not observers.include? observer
				return
			end
	
			puts "add_observer: #{array} => #{method}"
							
			#TODO remove observers
			
			eval %{
				
				class << array
				
					alias_method :#{alias_name}, :#{method}
				
					def #{observersSym}
					
						@#{observersSym} = [] if @#{observersSym}.nil?
					
						@#{observersSym}
						
					end
					
					def #{method}(value)
					
						#{alias_name} value
						
						if @#{observersSym}
							@#{observersSym}.each do |observer|
								observer.#{method} value
							end
						end
						
					end
				
				end
				
			}
		
			array.send(observersSym) << self
			
		end
		
	end

end