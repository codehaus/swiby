#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/styles'
require 'swiby/layout/form'
require 'swiby/component/frame'
require 'swiby/component/button'
require 'swiby/component/section'

import javax.swing.JTable
import javax.swing.table.DefaultTableModel

class Symbol

  def / other_sym

    raise TypeError.new("Expected Symbol but was #{other_sym.class}") unless other_sym.instance_of?(Symbol)

    AccessorPath.new(self, other_sym)

  end

end

module Swiby

  module Builder
  
    def form &block

      ensure_section
      
      panel = Swiby::form(:as_panel, &block)
      
      context.add_child panel
      
      add panel
      context << panel
      layout_panel(panel)
      
    end
  
  end

  def dialog(parent, &block)
    
    sync_swing_thread do
      
      x = ::Frame.new(nil, true, parent)

      x.extend(Form)
      x.setup false

      x.instance_eval(&block) unless block.nil?

      x.refresh_tooltips
      x.apply_styles
      
      x
      
    end
    
  end
  
  # valid options are :as_panel or :as_frame
  def form(*options, &block)

    sync_swing_thread do
      
      is_panel = false

      if options.length == 0
        is_panel = false
      elsif options[0] == :as_panel
        is_panel = true
      end

      if is_panel
        x = ::Panel.new
      else
        x = ::Frame.new
      end

      x.extend(Form)
      x.setup is_panel

      x.instance_eval(&block) unless block.nil?

      x.refresh_tooltips
      x.apply_styles

      x
    
    end

  end

  module Form

    def setup is_panel = false

      local_context = self #TODO pattern repeated at several places!

      self.instance_eval do

        @local_context = local_context

        def context()
          @local_context
        end

      end
      
      @section = nil

      if is_panel

        def self.refresh_tooltips
        end
      
        @content_pane = self.java_component
        
      else
        @content_pane = @default_layer
      end

    end

    
    def method_missing(symbol, *args)
      
      if @section.respond_to?(symbol)
        @section.send(symbol, *args)
      else
        super
      end
      
    end
    
    def content(*options, &block)

      layout = create_form_compatible_layout(*options)
      layout = default_layout unless layout
      
      @main_layout = layout
      @content_pane.layout = layout
    
      if layout.respond_to?(:add_layout_extensions)
        layout.add_layout_extensions self
      end
      
      instance_eval(&block) if block
      
      complete
      
    end
    
    def data obj
      @data = obj
    end

    def next_row
      @section = nil
      @main_layout.add_area :next_row
    end
    
    def commands *args, &block
      
      if block
        
        block.instance_eval(&block)

        the_form = self
        
        block.instance_eval do

          @the_form = the_form
        
          def block.data
            @the_form.data
          end

          def block.values
            @the_form
          end
 
          def block.context
            @the_form
          end
        
        end

      end
      
      args.each do |arg|
      
        case arg
        when :ok
      
          command "Ok", :name => :ok_but do

            valid = true
            
            if block.respond_to?(:on_validate)
              valid = block.on_validate
            end
            
            if block.respond_to?(:on_ok)
              block.on_ok
            elsif valid
              
              if @updaters

                @updaters.each do |proc|
                  proc.call false
                end

              end

              close

            end
            
          end
          
        when :cancel
      
          command "Cancel", :name => :cancel_but do
            if block.respond_to?(:on_cancel)
              block.on_cancel
            else
              close
            end
          end
          
        when :apply
      
          command "Apply", :name => :apply_but do

            valid = true
            
            if block.respond_to?(:on_validate)
              valid = !block.on_validate
            end
            
            if valid
              
              if block.respond_to?(:on_apply)
                block.on_apply
              else
                if @updaters

                  @updaters.each do |proc|
                    proc.call false
                  end

                end
              end

              context[:apply_but].enabled = false
              context[:restore_but].enabled = false if context[:restore_but]

            end

          end

        when :restore
      
          command "Restore", :name => :restore_but  do

            if block.respond_to?(:on_restore)
              block.on_restore
            else
              if @updaters

                @updaters.each do |proc|
                  proc.call true
                end

              end
            end
            
            context[:apply_but].enabled = false if context[:apply_but]
            context[:restore_but].enabled = false

          end
          
        end
        
      end

    end

    def section(title = nil, *options)

      if title.is_a?(Hash)
        options << title
        title = nil
      end
      
      expand = nil
      if options.last.is_a?(Hash)
        expand = options.last.delete(:expand)
        options.pop if options.last.size == 0
      end

      @layout = create_section_compatible_layout(*options)
      
      @layout = FormLayout.new(10, 5) unless @layout
      
      @section = Section.new title
      @section.layout = @layout
          
      if @layout.respond_to?(:add_layout_extensions)
        @layout.add_layout_extensions @section
      end
      
      x = options.length > 0? options[0] : {}
      context[x[:name].to_s] = @section if x[:name]
      
      context << @section
      context.add_child @section
      
      content {} unless @main_layout
      
      @content_pane.add @section.java_component

      @main_layout = default_layout unless @main_layout
      @main_layout.add_area @section, expand
    
      if @main_layout.respond_to?(:add_layout_extensions)
        @main_layout.add_layout_extensions self
      end

    end

    def add child
      @last_added = child
      @section.add child
    end
    
    def ensure_section()
      section if @section.nil?
    end

    def layout_button comp = nil
      @layout.add_command comp.java_component
    end

    def layout_label label
      @layout.add_panel label.java_component
    end
    
    def layout_input label, text 
      if label
        @layout.add_field label.java_component, text.java_component
      else
        @layout.add_field label, text.java_component
      end
    end
    
    def layout_list label, list
      if label
        @layout.add_component label.java_component, list.java_component
      else
        @layout.add_component label, list.java_component
      end
    end

    def layout_panel panel
      @layout.add_panel panel.java_component
    end
    
    def complete
      
      if context[:apply_but] or context[:restore_but]
      
        context.each(TextField) do |tf|

          tf.on_change do
            context[:apply_but].enabled = true if context[:apply_but]
            context[:restore_but].enabled = true if context[:restore_but]
          end
          
        end
        
        context[:apply_but].enabled = false if context[:apply_but]
        context[:restore_but].enabled = false if context[:restore_but]
          
      end
      
    end

    def create_form_compatible_layout(*options)
      
      layout = create_layout(*options)

      if layout and !layout.respond_to?(:add_area)
        
        def layout.add_area panel, expand = nil
        end
        
      end
      
      layout
      
    end

    def create_section_compatible_layout(*options)
      
      layout = create_layout(*options)

      if layout and !layout.respond_to?(:add_command)
        
        def layout.add_command command
        end
        def layout.add_field label, text
        end
        def layout.add_component label, comp
        end
        def layout.add_panel panel
        end
        
      end
      
      layout
      
    end
    
    def default_layout
      
      layout_manager = MigLayout.new("", "grow", "grow")
      
      def layout_manager.add_area section, expand = nil
        
        span_it = @last_section.nil?
          
        if section == :next_row
          setComponentConstraints @last_section .java_component, "grow, wrap" if @last_section
          @current_row_size = nil
          @last_section = nil
        else

          if @rows_constraint.nil?
            
            @current_row_size = expand ? expand : 0
            
            @rows_constraint = '[grow]' unless expand
            @rows_constraint = "[#{expand}%]" if expand
            @previous_rows_constraint = ''
            
            setRowConstraints @rows_constraint
            
          elsif @current_row_size.nil?
            
            @current_row_size = 0
            
            @previous_rows_constraint = @rows_constraint
            
            @rows_constraint += '[grow]' unless expand
            @rows_constraint += "[#{expand}%]" if expand
            
            setRowConstraints @rows_constraint
            
          elsif expand and expand > @current_row_size
            
            @current_row_size = expand
            
            @rows_constraint = "#{@previous_rows_constraint}[#{expand}%]"
            
            setRowConstraints @rows_constraint
            
          end
        
          setComponentConstraints @last_section.java_component, "grow" if @last_section
          
          setComponentConstraints section.java_component, "grow #{expand}, span" if span_it
          setComponentConstraints section.java_component, "grow #{expand}" unless span_it
          
          @last_section = section
          
        end
        
      end
      
      layout_manager
      
    end
    
  end

end