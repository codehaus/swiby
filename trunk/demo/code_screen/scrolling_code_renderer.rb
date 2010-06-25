#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/2d'

import java.text.AttributedString

import java.awt.Color
import java.awt.font.TextAttribute
import java.awt.font.FontRenderContext
import java.awt.geom.AffineTransform

class TextCompositeShape
  
  attr_reader :glyph_sequence, :color, :width
  attr_reader :text # useful for debugging
  
  def initialize glyph_sequence, color, width, text
    @text = text
    @glyph_sequence, @color, @width = glyph_sequence, color, width
  end
  
end

module RendererStyles

  GREEN = Color.new(123, 232, 76)
  DARK_GREEN = GREEN.darker
  LIGHT_GREEN = Color.new(123, 255, 96)

  FONT = Graphics.create_font('courier', Font::PLAIN, 14)
  BOLD_FONT = Graphics.create_font('courier', Font::BOLD, 14)
  
  FONT_RENDER_CONTEXT = FontRenderContext.new(nil, true, true)
  
end

class ScrollingCodeRenderer
  
  include RendererStyles
  
  def initialize lines_as_tokens
    
    @lines_as_shapes = TokenToGraphicShapeConverter.new(lines_as_tokens).convert
  
    metrics = FONT.get_line_metrics("a", FONT_RENDER_CONTEXT)
    @height = metrics.height
    @width = metrics.ascent

    @animation_position = 0
    
  end
  
	def paint graphics

		y = 0
		
    @lines_as_shapes.each do |line_as_shapes|
      
      y += @height
      x = @animation_position
      
      line_as_shapes.each do |composite_shape|
			
        graphics.color composite_shape.color
        graphics.draw_glyphed_text composite_shape.glyph_sequence, x, y

        x += composite_shape.width
        
      end
    
    end
    
	end

  def forward
    @animation_position -= 1
  end
  
end

class TokenToGraphicShapeConverter
  
  include RendererStyles
  
  def initialize tokens_by_line
    @tokens_by_line = tokens_by_line
  end
  
  def convert
    
    @lines_as_shapes = []
    
    @tokens_by_line.each do |line_tokens|
      add_converted_line_into_shapes line_tokens
    end
    
    @lines_as_shapes
    
  end
  
  private
  
  def add_converted_line_into_shapes line_tokens

    @line_shapes = []
    @same_style_text = nil
    
    line_tokens.each do |token|
      
      if token.keyword?
        add_pending_normal
        add_keyword token.text        
      elsif token.value?
        add_pending_normal
        add_value token.text        
      else
        
        @same_style_text = '' unless @same_style_text
        @same_style_text += token.text
      
      end
      
    end
    
    add_pending_normal
      
    @lines_as_shapes << @line_shapes

  end
  
  def add_keyword text
        
    @line_shapes << create_glyph_schape_sequence(text[0, 1], BOLD_FONT, LIGHT_GREEN)
    @line_shapes << create_glyph_schape_sequence(text[1..-1], BOLD_FONT, GREEN)
    
  end
  
  def add_value text
    
    @line_shapes << create_glyph_schape_sequence(text, FONT, DARK_GREEN)
    
  end

  def add_pending_normal
    
    @line_shapes << create_glyph_schape_sequence(@same_style_text, FONT, GREEN) if @same_style_text
    
    @same_style_text = nil
    
  end
  
  def create_glyph_schape_sequence text, font, color
    
    glyph_sequence = font.create_glyph_vector FONT_RENDER_CONTEXT, text
    
    width = rotate_glyphs(glyph_sequence)
    
    TextCompositeShape.new glyph_sequence, color, width, text
    
  end
  
  def rotate_glyphs glyph_sequence
    
    x = 0.0
    spacing = 4.0
    
    n = glyph_sequence.num_glyphs
    
    n.times do |i|
      
      transform = AffineTransform.new
      transform.rotate Math::PI / 2
      
      gm = glyph_sequence.get_glyph_metrics(i)
      pos = glyph_sequence.get_glyph_position(i)

      pos.set_location x, pos.y - gm.bounds2D.width / 2
      
      x += gm.bounds2D.height + spacing
      
      glyph_sequence.set_glyph_position i, pos
      glyph_sequence.set_glyph_transform i, transform
      
    end
    
    width = x
    
  end
  
end
