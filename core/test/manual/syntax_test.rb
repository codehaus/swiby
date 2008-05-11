#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/form'
require 'swiby/tools/console'

import java.awt.Dimension

usage_text = '<html><font size="5">Tooltips for every component displays their name.<br>' +
             'Clicking or selecting should show a message.</font>'

initial_selection = 'Initial selection'
list_data = ['Line 1', 'Line 2', initial_selection]

def show_console context

  unless @console
    @console = open_console(context)
  end

  @console.visible = true if not @console.visible?

end

form {
  
  title 'All in blocks'
  
  width 600
  height 550
  
  content {
    section 'Label'
      label {
        name :label_name
        label 'label text at bottom [label_name]'
        swing { |comp|
          comp.vertical_alignment = BOTTOM
          comp.preferred_size = Dimension.new(200, 100)
          comp.border = ::BorderFactory.createLineBorder(AWT::Color::BLACK)
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      }

    section 'TextField'
      input {
        name :input_name
        label 'Label:'
        text 'read-only and disabled [input_name]'
        swing { |comp|
          comp.editable = false
          comp.enabled = false
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      }
    
    next_row
    section 'Combo box'
      combo {
        name :combo_name
        label 'Combo [combo_name]'
        values list_data
        selected initial_selection
        action { |value|
          message_box "You selected: #{value}"
        }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      }
    section 'List'
      list {
        name :list_name
        label 'List [list_name]'
        values list_data
        selected initial_selection
        action { |value|
          message_box "You selected: #{value}"
        }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      }

    next_row
    section 'Radio Group'
      radio_group {
        name :radio_group_name
        label 'List [radio_group_name]'
        values list_data
        selected initial_selection
        action { |value|
          message_box "You selected: #{value}"
        }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      }
    
    next_row
    section 'Check box'
      check {
        name :check_name
        text 'diabled [check_name]'
        enabled false
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      }
      check {
        name :check_name_2
        text 'enabled [check_name_2]'
        enabled true
        action {
          message_box "Clicked!"
        }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      }
    section 'Radio button'
      radio {
        name :radio_name
        text 'diabled [radio_name]'
        enabled false
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      }
      radio {
        name :radio_name_2
        text 'diabled [radio_name_2]'
        enabled true
        action {
          message_box "Clicked!"
        }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      }
    
    next_row
    section 'Button'
      button {
        name :button_name
        text 'disabled [button_name]'
        enabled false
        action {
          message_box "Action executed"
        }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      }

      button {
        text 'Console'
        action {
          show_console context
        }
      }
     
    next_row
      label usage_text
     
  }
  
  visible true
  
}

form {
  
  title 'Compact syntax'
  
  width 600
  height 550

  content {
    section 'Label'
      label 'label text at bottom', :label_name
        swing { |comp|
          comp.vertical_alignment = BOTTOM 
          comp.preferred_size = Dimension.new(200, 100)
          comp.border = ::BorderFactory.createLineBorder(AWT::Color::BLACK)
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
  
    section 'TextField'
      input 'Label;', 'read-only and disabled [input_name]', :name => :input_name
        swing { |comp|
          comp.editable = false
          comp.enabled = false
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      
    next_row
    section 'Combo box'
      combo('Combo [combo_name]', list_data, 
        initial_selection, :name => :combo_name) { |value|
          message_box "You selected: #{value}"
        }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
    section 'List'
      list('List [list_name]', list_data, 
          initial_selection, :name => :list_name) { |value|
          message_box "You selected: #{value}"
        }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
        
    next_row
    section 'Radio Group'
      radio_group('List [radio_group_name]', list_data,
        initial_selection, :name => :radio_group_name) { |value|
          message_box "You selected: #{value}"
        }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }

    next_row
    section 'Check box'
      check 'diabled [check_name]', :check_name, :enabled => false
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      check('enabled [check_name_2]', :check_name_2) {
        message_box "Clicked!"
      }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
        
    section 'Radio button'
      radio('diabled [radio_name]', :radio_name, :enabled => false)
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
      radio('diabled [radio_name_2]', :radio_name_2) {
        message_box "Clicked!"
      }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }
    
    next_row
    section 'Button'
      button('disabled [button_name]', :button_name, :enabled => false) {
        message_box "Action executed"
      }
        swing { |comp|
          comp.tool_tip_text = "My name is <#{comp.name}>"
        }

    button('Console') {
      open_console context
    }

    next_row
      label usage_text
  }
  
  visible true
  
}
