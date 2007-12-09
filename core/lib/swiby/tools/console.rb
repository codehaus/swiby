#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/form'
require 'swiby/swing/event'
require 'swiby/util/ruby_tokenizer'

include_class 'javax.swing.JLayeredPane'
include_class 'javax.swing.text.StyleConstants'
include_class 'javax.swing.text.StyledEditorKit'

styles {
  editor(
    :font_family => Styles::COURIER,
    :font_size => 12
  )
}    

# returns a form (Swiby#Frame) that publishes a #run_context=
# method to change the running context (form)
def open_console run_context, container = nil
  
  container = run_context unless container
  
  frm = form do
    
    @container = container
    @run_context = run_context

    title "Console"
    
    editor 400, 300, :name => :editor
    
    button "Show Info", :name => :frame_info_button do
      context.show_hide_info
    end
    button "Execute" do
      context.execute(context[:editor].text)
    end
    button "Close" do
      close
    end
    
    on_close do
      context.hide_info
    end
    
    visible true
    dispose_on_close
    
  end
  
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
  StyleConstants::set_foreground(style, AWT::Color::BLACK)
  
  style = doc.add_style("name", nil)
  StyleConstants::set_foreground(style, AWT::Color::BLACK)
  
  style = doc.add_style("keyword", nil)
  StyleConstants::set_foreground(style, AWT::Color::BLUE)
  StyleConstants::set_bold(style, true)

  style = doc.add_style("symbol", nil)
  StyleConstants::set_foreground(style, AWT::Color::BLUE)
  
  style = doc.add_style("number", nil)
  StyleConstants::set_foreground(style, AWT::Color::RED)
  
  style = doc.add_style("string", nil)
  StyleConstants::set_foreground(style, AWT::Color::ORANGE)
  
  style = doc.add_style("comment", nil)
  StyleConstants::set_foreground(style, AWT::Color::GREEN)
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

class FrameInfoPanel
  
  #TODO make it part of Swiby wrappers?
  #TODO button in Windows L&F hide the "index marker" (cause highlight when mouse over)

  def initialize parent, target
    
    @markers = []
    @parent = parent
    @target = target
    @panel = JPanel.new

    @panel.visible = false
    @panel.opaque = false
    @panel.layout = nil
    
    create_markers

    parent.java_component.layered_pane.add(@panel, JLayeredPane::POPUP_LAYER)

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
    
    origin = @parent.java_component.content_pane.location_on_screen

    @markers.each_index do |i|
    
      d = @markers[i].preferred_size
      p = @target[i].java_component.location_on_screen

      @markers[i].set_bounds(p.x - 2 - origin.x, p.y - 4 - origin.y, d.width, d.height)
    
    end
    
  end
  
  private
  
  def create_markers
    
    unless @bg_color
      @bg_color = AWT::Color.new(255, 255, 128)
      @no_name_bg = AWT::Color.new(248, 248, 248)
      outside = Swing::BorderFactory.createLineBorder(AWT::Color::BLACK)
      inside = Swing::BorderFactory.createEmptyBorder(1, 2, 1, 2)
      @border = Swing::BorderFactory.createCompoundBorder(outside, inside)
    end
    
    index = 0
    
    @target.each do |comp|

      text = 
        "<html>" +
        "<b>Name:</b> #{comp.name}<br>" +
        "<b>Class:</b> #{comp.class}<br>" +
        "<b>Java:</b> #{comp.java_component.class}" +
        "</html>"
      
      l = JLabel.new(index.to_s)

      l.setBorder(@border)

      l.setOpaque(true)
      l.setBackground(comp.name.nil? ? @no_name_bg : @bg_color)
      l.setToolTipText(text)

      @panel.add(l)
      
      @markers << l
      
      index += 1
      
    end
    
  end
  
end

if $0 == __FILE__
  
  if ARGV.length > 0
    
    alias :form_original :form
    
    def form *args, &block
      $main_form = form_original(*args, &block)
    end
    
    load ARGV[0]
    
    open_console $main_form
    
  end
  
end