# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/form'
require 'swiby/component/layer'
require 'swiby/component/editor'

require 'swiby/swing/event'
require 'swiby/util/ruby_tokenizer'

include_class 'javax.swing.JLayeredPane'
include_class 'javax.swing.text.StyleConstants'
include_class 'javax.swing.text.StyledEditorKit'

class ScriptBuffer
  
  attr_accessor :text, :file
  
  def initialize
    @text = ''
  end
  
end

class ConsoleContext
  
  def initialize editor, info
    
    @buffers = []
    
    @editor, @info = editor, info
    
    new

  end
  
  def save
    
    file = @buffers[@pos].file
    
    if file == nil
      
      chooser = javax.swing.JFileChooser.new
      
      response = chooser.showSaveDialog(@editor.java_component.parent)
      
      return unless response == javax.swing.JFileChooser::APPROVE_OPTION
      
      @buffers[@pos].file = chooser.getSelectedFile.getAbsolutePath
      
    end
    
    @buffers[@pos].text = @editor.java_component(true).text
    
    file = @buffers[@pos].file
    
    File.open(file, 'w') {|f| f.write(@buffers[@pos].text) }
    
  end

  def open file = nil
    
    if file == nil
      
      chooser = javax.swing.JFileChooser.new
      
      response = chooser.showOpenDialog(@editor.java_component.parent)
      
      return unless response == javax.swing.JFileChooser::APPROVE_OPTION
      
      file = chooser.getSelectedFile.getAbsolutePath
      
    end
    
    create_buffer file, IO.readlines(file).join
    
  end

  def new file = nil
    create_buffer file, ''
  end
  
  def edit name = nil
    
    new_pos = -1
    
    (0...@buffers.length).each do |i|
      
      buffer = @buffers[i]
      
      if buffer.file.nil? and name.nil?
        new_pos = i
        break
      end
      
      next if buffer.file.nil?
      
      if buffer.file == name
        new_pos = i
        break
      end
      
      file = File.basename(buffer.file)
      
      if file == name
        new_pos = i
        break
      end
      
      file = File.basename(buffer.file, '.rb')
      
      if file == name
        new_pos = i
        break
      end
      
    end

    return if new_pos < 0
    
    change_buffer @buffers[new_pos]
    
    @pos = new_pos

  end
  
  def next_buffer
    
    pos = @pos
    pos = -1 if pos + 1 == @buffers.length
    pos += 1
    
    change_buffer @buffers[pos]
    
    @pos = pos
    
  end
  
  def previous
    
    pos = @pos
    pos = @buffers.length if pos == 0
    pos -= 1
    
    change_buffer @buffers[pos]
    
    @pos = pos
    
  end
  
  private
  
  def create_buffer file, content
  
    buffer = ScriptBuffer.new
    
    buffer.file = file
    buffer.text = content
    
    change_buffer buffer
    
    @buffers << buffer

    @pos = @buffers.length - 1

  end

  def change_buffer buffer
    
    @buffers[@pos].text = @editor.java_component(true).text if @pos
    
    @info.value = buffer.file
    @editor.java_component(true).text = buffer.text
    @editor.java_component(true).grab_focus
    
  end
  
end

# returns a form (Swiby#Frame) that publishes a #run_context=
# method to change the running context (form)
def open_console run_context, container = nil
  
  container = run_context unless container
  
  styles = create_styles {
    label(
      :color => :white
    )
    info {
      input(
        :color => :white,
        :background_color => 0x727272
      )
    }
    popup {
      container(
        :border_color => 0x700418,
        :background_color => 0x6c0000
      )
    }
  }
  
  frm = form {
    
    use_styles styles
    
    @container = container
    @run_context = run_context

    width 500
    height 300
    
    title "#{container.java_component.title} - Console"
    
    text :name => :info

    next_row
    section :expand => 100
      editor :name => :editor
    
    button("Show Info", :name => :frame_info_button) {
      context.show_hide_info
    }
    button("Execute") {
      context.execute(context[:editor].text)
    }
    button("Close") {
      close
    }
    
    on_close {
      context.hide_info
    }
    
    layer(:popup) {
      content(:layout => :form, :vgap => 10, :hgap => 10) {
        input 'Command:', '', :name => :command, :columns => 40
        button 'Close', :close
      }
    }
    
    global_shortcut(ctl_key(cr_key)) {
      context.layers[:popup].visible true
      context.layers[:popup][:command].java_component.grab_focus
    }
    
    visible true
    dispose_on_close
    
  }
  
  console_context = ConsoleContext.new(frm['editor'], frm[:info])
  
  frm.layers[:popup][:command].on_keyboard esc_key{
    frm.layers[:popup].visible false
    frm[:editor].java_component(true).grab_focus
  }
  frm.layers[:popup][:command].on_keyboard cr_key{
    begin
      
      cmd = frm.layers[:popup][:command].java_component.text
      
      cmd.strip!
      cmd = 'next_buffer' if cmd == 'next'
      
      console_context.instance_eval(cmd)
      
      frm.layers[:popup].visible false
      frm[:editor].java_component(true).grab_focus
      
    rescue Exception => ex
      message_box "Error: #{ex}"
    end
  }
  
  frm.layers[:popup][:command].on_focus_lost {
    frm.layers[:popup].visible false
    frm[:editor].java_component(true).grab_focus
  }
  
  setup_as_script_editor frm['editor'], RubyTokenizer.new
  
  def frm.run_context= run_context
    
    hide_info
    
    @run_context = run_context
    @info_pane.change_target(run_context) if @info_pane
    
  end
  
  def frm.execute script
    @run_context.instance_eval(script)
  end
  
  def frm.hide_info
    if @info_pane and @info_pane.visible?
      show_hide_info
    end
  end
  
  def frm.show_hide_info
      
    @info_pane = FrameInfoPanel.new(@container, @run_context) unless @info_pane

    if @info_pane.visible?
      @info_pane.visible = false
      self[:frame_info_button].text = "Show Info"
    else
      @info_pane.visible = true
      self[:frame_info_button].text = "Hide Info"
    end

  end
  
  frm
  
end

def setup_as_script_editor editor, tokenizer
  
  editor.instance_eval do
    
    @tokenizer = tokenizer
    
    def tokenize
      script = self.text.gsub(/\r\n/, "\n")
      @tokenizer.tokenize(script)
    end
    
  end
  
  editor.editor_kit = StyledEditorKit.new
  
  doc = editor.document
  
  style = doc.add_style("default", nil)
  StyleConstants::set_foreground(style, Color::BLACK)
  
  style = doc.add_style("name", nil)
  StyleConstants::set_foreground(style, Color::BLACK)
  
  style = doc.add_style("keyword", nil)
  StyleConstants::set_foreground(style, Color::BLUE)
  StyleConstants::set_bold(style, true)

  style = doc.add_style("symbol", nil)
  StyleConstants::set_foreground(style, Color::BLUE)
  
  style = doc.add_style("number", nil)
  StyleConstants::set_foreground(style, Color::RED)
  
  style = doc.add_style("string", nil)
  StyleConstants::set_foreground(style, Color::RED)
  
  style = doc.add_style("comment", nil)
  StyleConstants::set_foreground(style, Color.new(21, 110, 30))
  StyleConstants::set_italic(style, true)

  editor.on_change do
    
    tokens = editor.tokenize

    editor.invoke_later do

      #TODO improve algorithm instead of clearing all styles each time...
      doc = editor.document

      doc.set_character_attributes(0, doc.length, doc.get_style("default"), true);

      tokens.each do |token|
        doc.set_character_attributes(token.offset, token.length, doc.get_style(token.type.to_s), true);
      end
      
    end
    
  end

end

Marker = Struct.new(:info_label, :target)

class FrameInfoPanel
  
  #TODO make it part of Swiby wrappers?
  #TODO button in Windows L&F hide the "index marker"

  def initialize parent, target
    
    @markers = []
    @parent = parent
    @target = target
    @panel = JPanel.new
    
    @panel.visible = false
    @panel.opaque = false
    @panel.layout = nil
    @panel.setBounds 0, 0, 0, 0
    
    create_markers

    parent.java_component.layered_pane.add @panel
    parent.java_component.layered_pane.set_layer @panel, javax.swing.JLayeredPane::POPUP_LAYER

    listener = HierarchyBoundsListener.new
    
    listener.register :resized do
      layout
    end
    
    @panel.addHierarchyBoundsListener(listener)
    
  end

  def visible?
    @panel.visible?
  end

  def visible= flag
    
    @panel.setBounds(0, 0, @parent.java_component.width, @parent.java_component.height) if flag
    
    @panel.set_visible(flag)
    
    self.layout if flag
    
  end
  
  def change_target target
    
    @target = target
    @panel.remove_all
    
    @markers.clear
    
    create_markers
    
  end
  
  def layout
    
    @panel.setBounds(0, 0, @parent.java_component.width, @parent.java_component.height)
    
    origin = @parent.default_layer.location_on_screen

    @markers.each do |marker|
    
      d = marker.info_label.preferred_size
      p = marker.target.java_component.location_on_screen

      marker.info_label.set_bounds(p.x - 2 - origin.x, p.y - 4 - origin.y, d.width, d.height)
    
    end
    
  end
  
  private
  
  def create_markers
    
    unless @bg_color
      @bg_color = Color.new(255, 255, 128)
      @no_name_bg = Color.new(248, 248, 248)
      outside = ::BorderFactory.createLineBorder(Color::BLACK)
      inside = ::BorderFactory.createEmptyBorder(1, 2, 1, 2)
      @border = ::BorderFactory.createCompoundBorder(outside, inside)
    end
    
    index = {}
    
    @target.inject(true, @markers) do |comp|

      text = 
        "<html>" +
        "<b>Name:</b> #{comp.name}<br>" +
        "<b>Class:</b> #{comp.class}<br>" +
        "<b>Java:</b> #{comp.java_component.class}" +
        "</html>"
      
      parent_id =  comp.java_component.parent.object_id
      index[parent_id] = 0 unless index[parent_id]
      
      l = JLabel.new(index[parent_id].to_s)

      l.setBorder(@border)

      l.setOpaque(true)
      l.setBackground(comp.name.nil? ? @no_name_bg : @bg_color)
      l.setToolTipText(text)

      @panel.add(l)
      
      index[parent_id] += 1

      Marker.new(l, comp)
      
    end
    
  end
  
end

if $0 == __FILE__
  
  if ARGV.length > 0
    
    alias :frame_original :frame
    alias :form_original :form
    
    def form *args, &block
      $main_form = form_original(*args, &block)
    end
    
    def frame *args, &block
      $main_form = frame_original(*args, &block)
    end
    
    require ARGV[0]
    
    open_console $main_form
    
  end
  
end