#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby
  
  module Builder
    
    VALID_LAYERS = {
      :default => javax.swing.JLayeredPane::DEFAULT_LAYER, 
      :popup => javax.swing.JLayeredPane::POPUP_LAYER, 
      :drag => javax.swing.JLayeredPane::DRAG_LAYER,
      :palette => javax.swing.JLayeredPane::PALETTE_LAYER, 
      :modal => javax.swing.JLayeredPane::MODAL_LAYER
    }
    
    def layer name, options = nil, &block
      
      return unless @layers
      
      puts "#{__FILE__}:#{__LINE__} Warning: invalid layer name #{name}" unless name.is_a?(Integer) or VALID_LAYERS.has_key?(name)

      options = {} unless options
      options[:name] = name
      
      pane = create_panel(options)
      pane.instance_eval(&block) unless block.nil?
      
      layered = context.java_component.layered_pane
      
      z_index = name.is_a?(Integer) ? name : VALID_LAYERS[name]
      
      pane.java_component.opaque = false unless name.is_a?(Symbol)
      
      layered.add pane.java_component
      layered.set_layer pane.java_component, z_index
      
      @layers[name] = pane
      
      pane.visible false
      
    end
    
  end

end