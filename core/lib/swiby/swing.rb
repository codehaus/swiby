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
require 'swiby/swing/string'
require 'swiby/builder'
require 'swiby/style_resolver'
require 'swiby/layout_factory'

require 'java'
require 'erb'

import java.lang.System
import javax.swing.UIManager
import javax.swing.JOptionPane

module Swiby

  UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()) unless System::get_property('swing.defaultlaf')

  
  # top is the java component instance that is the top element
  # from which to start dumping hierachy components' information
  def dump_hierachy msg, top, indent = ''
    puts "#{indent}#{msg}: #{top.class} <layout #{top.get_layout.class}> contains #{top.component_count} component(s)"
    top.component_count.times do |i|
      comp = top.getComponent(i)
      dump_hierachy "[#{i}]",  comp, indent + ' '
    end
  end

  # top is the java component instance that is the top element
  # from which to start dumping hierachy components' sizes
  def dump_hierachy_sizes msg, top, indent = ''
    
    puts "for each component display preferred, minimum and maximum sizes" if indent.length == 0
    
    s = top.preferred_size
    min = top.minimum_size
    max = top.maximum_size
    
    puts "#{indent}#{msg}: #{top.class} [#{s.width} x #{s.height}] - [#{min.width} x #{min.height}] - [#{max.width} x #{max.height}]"
    
    top.component_count.times do |i|
      comp = top.getComponent(i)
      dump_hierachy_sizes "[#{i}]",  comp, indent + ' '
    end
    
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

      if runnable.failed?
        runnable.error.backtrace
        raise runnable.error
      end
      
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
    def self.width= width
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
    
    def find key
      
      key = key.to_s
      
      return @kids_by_name[key] if @kids_by_name.has_key?(key)
      
      @kids.each do |kid|
        
        comp = kid.find(key) if kid.respond_to?(:find)
        
        return comp if comp
          
      end
        
      nil
      
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
    
    #
    # Returns an array that is the result of iteration of the given block over all
    # components of this container or all the components if no block is given.
    #
    # If +deep+ is +true+ it also collects recursively the components of the containers
    #
    # The block receives the component and the level, starting at 0, each time the
    # iteration goes one level deeper the level is increment by 1
    #
    # EXAMPLE
    #   # container contains 2 components a button named 'b1' and a lable named 'label1'
    #   container.collect { |comp, level| comp.name }
    #     => ['b1', 'label1']
    #   container.collect
    #     => [#<Swiby::Button:0x11067af>, #<Swiby::Label:0x1591b4d>]
    #   container.collect { |comp, level| "#{level}: #{comp.name}" }
    #     => ['0: b1', '0: label1']
    #
    def collect deep = true, level = 0, &block
      
      components = []
      
      @kids.each do |comp|
        
        components << comp unless block_given?
        components << yield(comp, level) if block_given?
        
        if deep and comp.respond_to?(:each)
          children = comp.collect(true, level + 1, &block)
          components.concat children
        end
        
      end
      
      components
      
    end

    #
    # Behaves as +collect+ but fills the given collection. It returns the same collection.
    #
    # The advantage of +inject+ is that less temporary arrays are created.
    #
    # see ComponentAccesssor.collect
    #
    def inject deep = true, result = [], level = 0, &block
      
      @kids.each do |comp|
        
        result << comp unless block_given?
        result << yield(comp, level) if block_given?
        
        if deep and comp.respond_to?(:each)
          comp.inject(true, result, level + 1, &block)
        end
        
      end
      
      result
      
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
      self.layout_manager = layout if layout

      if layout.respond_to?(:add_layout_extensions)
        layout.add_layout_extensions self
      end
      
      self.instance_eval(&block)
      
      content_done
      
    end
    
    def layout_manager= layout
      @component.layout = layout
    end
    
    def change_content(*options, &block)
      
      @kids.clear
      @kids_by_name.clear
      
      java_component.remove_all
      
      content *options, &block
      
      java_component.validate
      java_component.repaint
      
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
  
  protected
  
  def content_done
  end
  
end
