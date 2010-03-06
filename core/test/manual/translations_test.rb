#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

$LOAD_PATH << File.dirname(__FILE__)

require 'swiby/tools/console'

require 'swiby/layout/stacked'

require 'swiby/component/text'
require 'swiby/component/radio_button'

import javax.swing.SwingConstants

Swiby::CONTEXT.add_translation_bundle "translations", :en, :fr

def show_console context

  unless @console
    @console = open_console(context)
  end

  @console.visible = true if not @console.visible?

end

class TranslationsTest < ManualTest

  initial_selection = 'Initial selection'
  list_data = ['Line 1', 'Line 2', initial_selection]
  
  manual 'Translations' do
    
    form {
      
      title 'Translations'
      
      width 600
      height 680
      
      def current_language
        Swiby::CONTEXT.language == :en ? 'English' : 'French'
      end
      
      def other_language
        Swiby::CONTEXT.language == :en ? 'french' : 'english'
      end
      
      tooltip_provider { |name, comp|
        :my_name.apply_substitution(binding) if name
      }
      
      content {
        section 'Label'
          label 'label text at bottom', :label_name
            swing { |comp|
              comp.vertical_alignment = SwingConstants::BOTTOM
              comp.preferred_size = Dimension.new(200, 100)
              comp.border = ::BorderFactory.createLineBorder(Color::BLACK)
            }
      
        section 'Text field'
          input 'Label', 'read-only and disabled [input_name]', :name => :input_name
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

        section 'Check box'
          check 'disabled [check_name]', :check_name, :enabled => false
          check('enabled [check_name_2]', :check_name_2) {
            message_box "Clicked!"
          }
            
        next_row
        section 'Radio button'
          radio('disabled [radio_name]', :radio_name, :enabled => false)
          radio('disabled [radio_name_2]', :radio_name_2) {
            message_box "Clicked!"
          }
        
        section 'Button'
          button('disabled [button_name]', :button_name, :enabled => false) {
            message_box "Action executed"
          }

        next_row
        section 'Language selection'
          list('Language', ['English', 'French'], current_language, :name => :language_list){ |value|
            switch_language value
          }
        
        next_row
        label :usage_text.dynamic_text
        hover_button(other_language, :name => :language_button){
          switch_language
        }
        
        command('Console') {
          open_console context
        }
        
        def switch_language language = nil
        
          if language
            language = language == 'English' ? :en : :fr
          else
            
            if Swiby::CONTEXT.language == :en
              language = :fr
            else
              language = :en
            end
          
          end
          
          Swiby::CONTEXT.language = language
          
          context[:language_list].value = current_language
          context[:language_button].text = other_language
          
        end
        
      }
      
      visible true
      
    }

  end
  
end