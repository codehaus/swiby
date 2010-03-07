#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/list'

import javax.swing.ListCellRenderer
 
module Swiby

  class HoverRenderer
    
    include ListCellRenderer
    
    def initialize actual
       @actual = actual
    end
    
    def getListCellRendererComponent list, value, index, is_selected, has_focus
      
      comp = @actual.getListCellRendererComponent(list, value, index, false, false)
      
      comp.foreground = Color::RED if is_selected
      
      comp
      
    end
    
  end
    
  def create_mouse_listener &block

    block.instance_eval(&block)
    
    listener = Swiby::MouseListener.new
    
    listener.register &block
    
    listener
    
  end
    
  def create_mouse_motion_listener &block

    block.instance_eval(&block)
    
    listener = Swiby::MouseMotionListener.new
    
    listener.register &block
    
    listener
    
  end

  def setup_list_view swiby_list, &handler
          
    comp = swiby_list.java_component
    comp.border = nil
    
    list = swiby_list.java_component(true)
    
    listener = create_mouse_listener do
      
      @list = list
      
      def on_mouse_out ev
        @list.clear_selection
      end
      
    end
    
    list.addMouseListener listener
    
    listener = create_mouse_motion_listener do
      
      @list = list
      @handler = handler
      @swiby_list = swiby_list
      
      def on_mouse_move ev
        
        row = @list.locationToIndex(ev.point)
        
        return if row < 0
        
        if not @list.get_cell_bounds(row, row + 1).contains(ev.point)
            @list.clear_selection
            return
        end
        
        return if @swiby_list.selection == row
        
        @list.selected_index = row
        
        @handler.call(@swiby_list.value) if @handler
        
      end
      
    end

    list.addMouseMotionListener listener
    
    list.cell_renderer = HoverRenderer.new(list.cell_renderer)
    
  end

  module Builder
    
    def list_view name, data, &block
      
      list_comp = list(data, :name => name)
      
      setup_list_view(list_comp, &block)
      
      list_comp
      
    end
    
  end
  
end