#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/tools/console'

require 'swiby/layout/stacked'

require 'swiby/component/text'
require 'swiby/component/radio_button'

import javax.swing.SwingConstants

def show_console context

  unless @console
    @console = open_console(context)
  end

  @console.visible = true if not @console.visible?

end

class SyntaxTest < ManualTest

  usage_text = '<html><font size="5">Tooltips for every component displays their name.<br>' +
               'Clicking or selecting should show a message.</font>'

  initial_selection = 'Initial selection'
  list_data = ['Line 1', 'Line 2', initial_selection]

  manual 'All in blocks' do

    form {
      
      title 'All in blocks'
      
      width 600
      height 620
      
      tooltip_provider { |name, comp| "My name is <#{comp.name}>" if name }
      
      content {
        section 'Label'
          label {
            name :label_name
            label 'label text at bottom [label_name]'
            swing { |comp|
              comp.vertical_alignment = SwingConstants::BOTTOM
              comp.preferred_size = Dimension.new(200, 100)
              comp.border = ::BorderFactory.createLineBorder(Color::BLACK)
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
          }

        next_row
        section 'Radio group'
          radio_group {
            name :radio_group_name
            label 'List [radio_group_name]'
            values list_data
            selected initial_selection
            action { |value|
              message_box "You selected: #{value}"
            }
          }
        
        next_row
        section 'Check box'
          check {
            name :check_name
            text 'disabled [check_name]'
            enabled false
          }
          check {
            name :check_name_2
            text 'enabled [check_name_2]'
            enabled true
            action {
              message_box "Clicked!"
            }
          }
        section 'Radio button'
          radio {
            name :radio_name
            text 'disabled [radio_name]'
            enabled false
          }
          radio {
            name :radio_name_2
            text 'disabled [radio_name_2]'
            enabled true
            action {
              message_box "Clicked!"
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
          }

          command {
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

  end
  
  manual 'Compact syntax' do
    
    form {
      
      title 'Compact syntax'
      
      width 600
      height 620

      tooltip_provider { |name, comp| "My name is <#{comp.name}>" if name }
      
      content {
        section 'Label'
          label 'label text at bottom', :label_name
            swing { |comp|
              comp.vertical_alignment = SwingConstants::BOTTOM 
              comp.preferred_size = Dimension.new(200, 100)
              comp.border = ::BorderFactory.createLineBorder(Color::BLACK)
            }
      
        section 'TextField'
          input 'Label:', 'read-only and disabled [input_name]', :name => :input_name
            swing { |comp|
              comp.editable = false
              comp.enabled = false
            }
          
        next_row
        section 'Combo box'
          combo('Combo [combo_name]', list_data, 
            initial_selection, :name => :combo_name) { |value|
              message_box "You selected: #{value}"
            }
        section 'List'
          list('List [list_name]', list_data, 
              initial_selection, :name => :list_name) { |value|
              message_box "You selected: #{value}"
            }
            
        next_row
        section 'Radio group'
          radio_group('List [radio_group_name]', list_data,
            initial_selection, :name => :radio_group_name) { |value|
              message_box "You selected: #{value}"
            }

        next_row
        section 'Check box'
          check 'disabled [check_name]', :check_name, :enabled => false
          check('enabled [check_name_2]', :check_name_2) {
            message_box "Clicked!"
          }
            
        section 'Radio button'
          radio('disabled [radio_name]', :radio_name, :enabled => false)
          radio('disabled [radio_name_2]', :radio_name_2) {
            message_box "Clicked!"
          }
        
        next_row
        section 'Button'
          button('disabled [button_name]', :button_name, :enabled => false) {
            message_box "Action executed"
          }

        command('Console') {
          open_console context
        }

        next_row
          label usage_text
      }
      
      visible true
      
    }

  end
  
end