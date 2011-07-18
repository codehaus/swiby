#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/2d'
require 'swiby/swing/timer'
require 'swiby/component/panel'

require 'swiby/layout/border'
  
module Swiby
    
  module Builder
  
    # +position+ is one of :north, :west, :east, :south
    # additional properties: :bg_color and :color (default to blue and white)
    # set +hint_text+ as :no_hint to prevent hint painting
    def auto_hide hint_text, position, *options, &block
      
      options = AutoHideOptions.new(context, hint_text, position, *options, &block)
      
      options[:layout] = :border unless options[:layout]
      
      options[:color] = Color::WHITE unless options[:color]
      options[:bg_color] = Color::BLUE unless options[:bg_color]
      
      pane = layer(:auto_hide, options, &block)
      
      unless context.glass_pane.is_a?(ControllingGlassPane)
        context.glass_pane = ControllingGlassPane.new(context)
        context.glass_pane.visible = true
        context.glass_pane.opaque = false
      end
      
      context.glass_pane.add_target position, pane, hint_text, options[:bg_color], options[:color]
      
      pane.instance_variable_set :@glass_pane, context.glass_pane
      
      def pane.swipe_out
        @glass_pane.animate_hide
      end
      def pane.swipe_in
        @glass_pane.animate_show
      end
      
      pane
      
     end

  end

  class AutoHideOptions < ComponentOptions
    
    define 'AutoHide' do
      
      strict false
      
      declare :hint_text, [String, Symbol], false
      declare :color, [Color], true
      declare :bg_color, [Color], true
      declare :position, [Symbol], false
      declare :name, [String, Symbol], true
      
      overload :hint_text, :position
      
    end

  end
  
  class ControllingGlassPane < javax.swing.JPanel
    
    def initialize parent
      
      super()
      
      @parent = parent
      @animating = false
      @last_visible = nil
      @auto_components = {}
      
    end
    
    def start
      show_hints
    end

    def add_target position, target, hint_text, bg_color, color

      painter = "paint_#{position}".to_sym
      
      raise "Invalid position: #{position}, no painter #{painter.inspect}" unless respond_to?(painter)
      
      target.visible false
      
      @auto_components[position] = AutoHideComponentInfo.new(position, target, hint_text, bg_color, color, painter)
      
    end
    
    def show_hints
      
      repeat(10, 200) do |count|
        
        @hint_alpha = 255 - count * 25
        @hint_alpha = nil if count == 10
        
        repaint
        
      end
      
    end
          
    def contains x, y
      
      if @last_visible
        @last_visible = nil unless @last_visible.target.visible?
      end
      
      unless @animating
      
        if @last_visible
          
          size = @last_visible.target.java_component.preferred_size
          
          if @last_visible.position == :north and size.height < y
            animate_hide
          elsif @last_visible.position == :south and height - size.height > y
            animate_hide
          elsif @last_visible.position == :west and size.width < x
            animate_hide
          elsif @last_visible.position == :east and width - size.width > x
            animate_hide
          end
        
        elsif y < 20 and @auto_components[:north]
          animate_show @auto_components[:north]
        elsif y > height - 20 and @auto_components[:south]
          animate_show @auto_components[:south]
        elsif x > width - 20 and @auto_components[:east]
          animate_show @auto_components[:east]
        elsif x < 20 and @auto_components[:west]
          animate_show @auto_components[:west]
        end
      
      end
      
      false
      
    end
    
    def paintComponent g
      
      super
      
      return unless @hint_alpha
      
      g = Graphics.new(self, g)
      
      w = width
      h = height

      @auto_components.each do |position, info|
        draw_hint info, g unless info.hint_text == :no_hint
      end
      
    end
    
    def draw_hint info, g
      
      col = info.hint_bg_color
      hint_bg_color = Color.new(col.red, col.green, col.blue, @hint_alpha)
      
      col = info.hint_color
      hint_color = Color.new(col.red, col.green, col.blue, @hint_alpha)
      
      send info.painter, info, g, hint_bg_color, hint_color
      
    end
    
    def paint_north info, g, hint_bg_color, hint_color
      
      g.color hint_bg_color
      g.fill_rect 0, 0, width, 20
      
      rc = g.string_bounds info.hint_text
      g.color hint_color
      g.draw_string info.hint_text, 10, 2 + rc.height
      
    end
    
    def paint_south info, g, hint_bg_color, hint_color
      
      g.color hint_bg_color
      g.fill_rect 0,  height - 20, width, 20
      
      rc = g.string_bounds info.hint_text
      g.color hint_color
      g.draw_string info.hint_text, 10, height - (rc.height / 2)
      
    end
    
    def paint_east info, g, hint_bg_color, hint_color
      
      x, y, w, h = east_rect
      
      g.color hint_bg_color
      g.fill_rect x, y, w, h
      
      rc = g.string_bounds info.hint_text
      g.translate width, y + 10
      g.rotate Math::PI/2
      g.color hint_color
      g.draw_string info.hint_text, 0, rc.height
      
      g.rotate -Math::PI/2
      g.translate -width, - (y + 10)
      
    end
    
    def paint_west info, g, hint_bg_color, hint_color
      
      x, y, w, h = west_rect
      
      g.color hint_bg_color
      g.fill_rect x, y, w, h
      
      rc = g.string_bounds info.hint_text
      g.translate 0, y + 10 + rc.width
      g.rotate -Math::PI/2
      g.color hint_color
      g.draw_string info.hint_text, 0, rc.height
      
      g.rotate Math::PI/2
      g.translate 0, -(y + 10 + rc.width)
      
    end
    
    private
    
    def east_rect
      
      x = width - 20
      y = 0
      
      w = 20
      h = height
      
      if @auto_components[:north]
        y += 20
        h -= 20
      end
      
      if @auto_components[:south]
        h -= 20
      end

      return x, y, w, h
      
    end
    
    def west_rect
      
      x = 0
      y = 0
      
      w = 20
      h = height
      
      if @auto_components[:north]
        y += 20
        h -= 20
      end
      
      if @auto_components[:south]
        h -= 20
      end

      return x, y, w, h
      
    end
    
    public
    
    def animate_show auto_info
      
      unless auto_info.target.visible?
        
        @parent.layers[:auto_hide] = auto_info.target
        
        size = auto_info.target.java_component.preferred_size
        
        if auto_info.position == :west or auto_info.position == :east
          h = height
          w = size.width
          step = w / 10
          y = 0
        else
          w = width
          h = size.height
          step = h / 10
          x = 0
        end
        
        if step < 10
          step *= 2
          n = 5
        else
          n = 10
        end
        
        if auto_info.position == :west
          x = -w + step
        elsif auto_info.position == :east
          x = width - step
          step = -step
        elsif auto_info.position == :north
          y = -h + step
        elsif auto_info.position == :south
          y = height - step
          step = -step
        end
        
        @animating = true
        
        repeat(n, 50) do |count|
          
          if count == n
          
            if auto_info.position == :west
              x = 0
            elsif auto_info.position == :east
              x = width - w
            elsif auto_info.position == :north
              y = 0
            elsif auto_info.position == :south
              y = height - h
            end
            
            @animating = false
            @last_visible = auto_info
            
          end
          
          auto_info.target.visible true
          auto_info.target.java_component.setBounds(x, y, w, h)
          
          if auto_info.position == :west or auto_info.position == :east
            x += step
          else
            y += step
          end
          
        end
        
      end
            
    end
    
    def animate_hide
      
      size = @last_visible.target.java_component.preferred_size
      
      if @last_visible.position == :west or @last_visible.position == :east
        h = height
        w = size.width
        step = w / 10
        y = 0
      else
        w = width
        h = size.height
        step = h / 10
        x = 0
      end
      
      if step < 10
        step *= 2
        n = 5
      else
        n = 10
      end
      
      if @last_visible.position == :west
        x = -step
      elsif @last_visible.position == :east
        x = width - size.width + step
        step = -step
      elsif @last_visible.position == :north
        y = -step
      elsif @last_visible.position == :south
        y = height - size.height + step
        step = -step
      end
      
      @animating = true
    
      repeat(n, 50) do |count|
        
        if count == n
          @last_visible.target.visible false
          @last_visible = nil
          @animating = false
        else
          
          @last_visible.target.java_component.setBounds(x, y, w, h)
          
          if @last_visible.position == :west or @last_visible.position == :east
            x -= step
          else
            y -= step
          end
          
        end
        
      end
      
    end
    
    class AutoHideComponentInfo
      
      attr_reader :painter
      attr_reader :position, :target
      attr_reader :hint_bg_color, :hint_color
      
      def initialize position, target, hint_text, bg_color, color, painter
        @painter = painter
        @position, @target = position, target
        @hint_text, @hint_bg_color, @hint_color = hint_text, bg_color, color
      end
      
      def hint_text
        @hint_text.translate
      end
      
    end
    
  end
    
end