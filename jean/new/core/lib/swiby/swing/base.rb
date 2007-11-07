#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/core'

require 'java'

module Swiby

  module AWT
    include_class 'java.awt.FlowLayout'
  end
  
  include_class 'javax.swing.JScrollPane'

  def message_box text
    JOptionPane.showMessageDialog nil, text
  end
  
  def exit (exit_code = 0)
    System::exit(exit_code)
  end
  
  def create_layout(layout)

    case layout
    when :left_flow
      layout = AWT::FlowLayout.new(AWT::FlowLayout::LEFT)
    when :center_flow
      layout = AWT::FlowLayout.new(AWT::FlowLayout::CENTER)
    when :rigth_flow
      layout = AWT::FlowLayout.new(AWT::FlowLayout::RIGHT)
    else
      layout = nil
    end

    layout
    
  end
  
  def create_icon(url)

    if url =~ /http:\/\/.*/
      url = java.net.URL.new(url)
    elsif url =~ /file:\/\/.*/
      url = url[7..-1]
    elsif File.exist?(url)
      url = "#{File.expand_path(url)}"
    else
      #TODO implement URL resolution using LOAD_PATH, for "local" files, URL like 'file://c:/..." does not work
      #puts $LOAD_PATH
      puts "url resolution not implemented"
      return nil
    end

    ImageIcon.new(url)

  end

  def to_human_readable(value)
    
    if value.respond_to? :humanize
      value.humanize
    elsif value.respond_to? :name
      value.name
    else
      value.to_s
    end

  end

  class SwingBase

    def self.swing_attr_accessor(symbol, *args)
      generate_swing_attribute to_map(symbol, args), :include_attr_reader
    end

    def self.swing_attr_writer(symbol, *args)
      generate_swing_attribute to_map(symbol, args)
    end

    def self.container(symbol)
      raise RuntimeError, "#{symbol} is not a Symbol" unless symbol.is_a? Symbol

      eval %{
        def #{symbol}(array = nil, &block)
          if array.nil?
            self.addComponents block.call
          else
            self.addComponents array
          end
        end
      }
    end

    def scrollable
      @scroll_pane = JScrollPane.new @component
    end

    def visible?
      @component.visible?
    end
    
    def visible= visible
      @component.visible = visible
    end
    
    def setBounds x, y, w, h
      @component.setBounds x, y, w, h
    end

    def install_listener iv
    end

    def java_component
      return @component if @scroll_pane.nil?
      @scroll_pane
    end

    def apply_styles
    end
    
    #TODO remove private because some calls to 'addComponents' were forbidden (with JRuby 1.0.1)
    #private

    def self.to_map(symbol, args)
      map = Hash.new
      fill_map map, symbol
      args.each {|sym| fill_map map, sym } unless args.nil?
      map
    end

    def self.fill_map(map, x)
      if x.is_a? Hash
        x.each do |k, v|
          raise RuntimeError, "#{k} must be a Symbol" unless k.is_a? Symbol
          map[k] = v
        end
      elsif x.is_a? Symbol
        map[x] = nil
      else
        raise RuntimeError, "#{x} must be a Symbol"
      end
      map
    end

    def self.generate_swing_attribute(map, include_attr_reader=nil)
      map.each do |symbol, javaName|
        javaName ||= symbol
        if include_attr_reader
          class_eval %{
            def #{symbol}
              @component.#{javaName}
            end
          }
        end

        class_eval %{

          def #{symbol}=(val)
            @component.#{javaName} = val
          end

          def #{symbol}
            @component.#{javaName}
          end

        }
      end

    end

    def addComponents(array)
      if array.respond_to? :each
        array.each do |comp|
          @component.add comp.java_component
        end
      else
        @component.add array.java_component
      end
    end
    
    swing_attr_accessor :name
    swing_attr_accessor :preferred_size
    
  end

end