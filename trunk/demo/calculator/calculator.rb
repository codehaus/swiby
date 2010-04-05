#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/form'

require 'swiby/layout/grid'

require 'swiby/mvc'
require 'swiby/mvc/text'
require 'swiby/mvc/label'
require 'swiby/mvc/button'

view = Swiby.define_view do

  names = {
    '=' => :compute,
    'C' => :clear, 'CE' => :clear_entry,
    'MC' => :clear_memory, 'MR' => :recall_memory
  }

  keyboard = ['MC', '7', '8', '9', '/','CE'] +
             ['MR', '4', '5', '6', '*', 'C'] +
             ['M+', '1', '2', '3', '-',  ''] +
             ['M-', '0', '.', '=', '+',  '']

  form {

    use_styles {
      root(
        :background_color => 0xD6CFE6,
        :font_family => Styles::VERDANA,
        :font_style => :normal,
        :font_size => 16
      )
      input(
        :color => :red,
        :background_color => 0xAAAAEE,
        :text_align => :right,
        :readonly => true
      )
    }
  
    title "Calculator"

    autosize

    content {

      text "0", :name => :entry

      grid(:columns => '[]5[][][]5[]10[]') {

        keyboard.each { |key|

          if key.length == 0
            label key
          else
            name = names[key]
            name = key.downcase unless name
            button key, :name => name
          end

        }

      }

    }

    visible true

  }

end

class Calculator

  attr_reader :value, :memory
  
  def initialize

    clear

    @ADD = Proc.new {@value = @value + @term}
    @DIVIDE = Proc.new {@value = @value / @term}
    @MULTIPLY = Proc.new {@value = @value * @term}
    @SUBSCTRACT = Proc.new {@value = @value - @term}

  end
  
  10.times do |i|
    define_method(i.to_s.to_sym) {
      @display = @display == '0' || @first ? i.to_s : @display + i.to_s
      @first = false
    }
  end

  define_method('.'.to_sym) {
    @display = @display + '.'
    @first = false
  }

  def -()
    operator @SUBSCTRACT
  end
  def *()
    operator @MULTIPLY
  end
  def /()
    operator @DIVIDE
  end
  def +()
    operator @ADD
  end

  def entry
    @display
  end

  def clear_entry
    @display = '0'
    @first = true
  end
  
  def compute
    
    @term = @display.to_f unless @first

    if @op
      @op.call
      format_display @value
    else
      format_display @term
    end

    @first = true
    
  end

  def clear

    @op = nil
    @value = 0

    clear_entry

  end

  def clear_memory
    @memory = nil
  end
  def may_clear_memory?
    not @memory.nil?
  end

  def recall_memory
    format_display @memory
    @value = @memory
    @first = true
  end
  def may_recall_memory?
    may_clear_memory?
  end

  define_method('m+'.to_sym) {
    value = @display.to_f
    @memory = @memory.nil? ? value : @memory + value
    @first = true
  }
  define_method('m-'.to_sym) {
    value = @display.to_f
    @memory = @memory.nil? ? -value : @memory - value
    @first = true
  }

  def operator command
    compute unless @first
    @op = command
    @value = @display.to_f
    @first = true
  end
  
  def format_display value
    value = value.to_s
    @display = value =~ /(.*)\.0*$/ ? $1 : value
  end
  
end

view.instantiate(Calculator.new) if $0 == __FILE__
