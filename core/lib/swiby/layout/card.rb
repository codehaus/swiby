#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

import java.awt.CardLayout

require 'swiby/layout_factory'
require 'swiby/component/panel'

module Swiby

  class CardLayoutFactory
  
    def accept name
      name == :card
    end
    
    def create name, data
          
      if data[:effect]
      
        effects = {
          :slide => org.javadev.effects.SlideAnimation,
          :cube => org.javadev.effects.CubeAnimation,
          :fade => org.javadev.effects.FadeAnimation,
          :radial => org.javadev.effects.RadialAnimation,
          :iris => org.javadev.effects.IrisAnimation,
          :dashboard => org.javadev.effects.DashboardAnimation
        }
        
        animation = effects[data[:effect]].new
        
        layout = org.javadev.AnimatingCardLayout.new(animation)
        
        layout.animation_duration = 500
        
      else
        layout = CardLayout.new
      end

      layout.hgap = data[:hgap] if data[:hgap]
      layout.vgap = data[:vgap] if data[:vgap]
          
      def layout.add_layout_extensions component

        return if component.respond_to?(:swiby_card__actual_add)

        class << component
          alias :swiby_card__actual_add :add
        end

        def component.add x

          if @card_name
            swiby_card__actual_add x, @card_name
          else
            raise "Card layout needs a current card name"
          end

        end

        def component.show_card name
          parent = default_layer
          cards = parent.getLayout()
          cards.show(parent, name.to_s)
        end
        
        def component.card name, options = nil, &block
          
          @card_name = name.to_s
          
          options = {} unless options
          
          raise "Expecting Hash as argument but was '#{options.class}'" unless options.is_a?(Hash)
          
          options[:name] = @card_name
          
          p = panel(options, &block)
          
          def p.show_card name
            parent = java_component.parent
            cards = parent.getLayout()
            cards.show(parent, name.to_s)
          end
          
          p
          
        end

      end

      layout
                
    end
    
  end
  
  LayoutFactory.register_factory(CardLayoutFactory.new)
  
end