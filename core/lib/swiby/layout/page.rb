#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import java.awt.BorderLayout

require 'swiby/layout_factory'

module Swiby

  class PageLayoutFactory
  
    def accept name
      name == :page
    end
    
    VALID_RULES = [:left, :right, :center, :expand, :fill, nil]
    
    def create name, data
          
      hgap = data[:hgap] ? data[:hgap] : 0
      vgap = data[:vgap] ? data[:vgap] : 0
      
      layout = MigLayout.new("ins 0, fill, gapx #{hgap}, gapy #{vgap}", '[]', '[pref!][]push[pref!]')
          
      def layout.add_layout_extensions component

        return if component.respond_to?(:swiby_dock__actual_add)

        class << component
          alias :swiby_dock__actual_add :add
        end

        component.instance_variable_set :@layout, self
        component.instance_variable_set :@body_row, 1
        component.instance_variable_set :@position, :body
        component.instance_variable_set :@expand_rule, nil
        component.instance_variable_set :@footer_component, nil
        component.instance_variable_set :@footer_expand_rule, nil
        
        def component.add x

          if @position
            
            if @position == :header
              row = 0
            elsif @position == :body
              
              row = @body_row
              
              @body_row += 1
              
              if @footer_component
                constraint = create_constraint(@body_row + 1, @footer_expand_rule)
                @layout.setComponentConstraints @footer_component.java_component, constraint
              end
              
              constraint = "[pref!]#{'[]' * (@body_row - 1)}#{@expand_rule == :fill ? '' : 'push'}[pref!]"
              
              @layout.setRowConstraints constraint
              
            else
              @footer_component = x
              row = @body_row + 1
            end
            
            constraint = create_constraint(row, @expand_rule)
            
            swiby_dock__actual_add x, constraint
            
          else
            swiby_dock__actual_add x
          end

        end

        def component.header expand_rule = nil
          @position = :header
          @expand_rule = expand_rule
        end

        def component.body expand_rule = nil
          @position = :body
          @expand_rule = expand_rule
        end

        def component.footer expand_rule = nil
          
          @position = :footer
          @expand_rule = expand_rule
          
          @footer_expand_rule = expand_rule
          
        end
        
        def component.create_constraint row, expand_rule
          
          validate_expansion_rule expand_rule
          
          if expand_rule == :expand or expand_rule == :fill
            "cell 0 #{row}, grow"
          elsif expand_rule == :right
            "cell 0 #{row}, align right"
          elsif expand_rule == :center
            "cell 0 #{row}, align center"
          else
            "cell 0 #{row}, align left"
          end
          
        end
        
        def component.validate_expansion_rule expand_rule
          raise "Invalid expansion rule value #{expand_rule.inspect}, expects one of #{VALID_RULES.inspect}" unless VALID_RULES.include?(expand_rule)
        end
        
      end

      layout
      
    end
    
  end
  
  LayoutFactory.register_factory(PageLayoutFactory.new)
  
end