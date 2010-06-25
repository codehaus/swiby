#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'code_tokenizer'
require 'scrolling_code_renderer'

require 'swiby'
require 'swiby/mvc/frame'
require 'swiby/mvc/draw_panel'

require 'swiby/swing/timer'

class CodeScreen

  def initialize
    load_tokenizers
  end
  
  def load_tokenizers
    
    Dir.glob("tokenizers/*.rb").each do |tokenizer_script|
      require tokenizer_script
    end

  end
  
  def scroll script
    
    tokens = tokenize(script)

    display_scrolling script, tokens
    
  end

  def tokenize script

    tokenizer = CodeTokenizer.create(script)

    unless tokenizer
      $stderr.puts "No parser for file '#{script}'. See tokenizers directory for existing parsers."
      exit 1
    end
    
    tokenizer.tokenized_code
    
  end

  def display_scrolling script, code_as_tokens_by_line, frequency_millis = 50
    
    renderer = ScrollingCodeRenderer.new(code_as_tokens_by_line)
    
    frame {
      
      width 900
      height 600
      
      title script
      
      @display = draw_panel(:resize_always => true) { |graphics|

        graphics.background Color::BLACK
        graphics.clear
        
        graphics.rotate(-Math::PI / 2)
        graphics.antialias = true
        
        renderer.paint graphics
        
      }
      
      visible true
      
      every(frequency_millis) {
        renderer.forward
        @display.repaint
      }
      
    }

  end

end

script = ARGV[0] ? ARGV[0] : __FILE__

CodeScreen.new.scroll(script)