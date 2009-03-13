#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'account'
require 'transfer'

require 'swiby/layout/stacked'
require 'swiby/component/combo'

import java.awt.Color

def open_settings target
  
  dialog(target) {
    
    title 'Settings...'
    
    width 300
    height 250
    
    use_styles $context.session.styles if $context.session.styles
    
    content {
      section 'Options'
        combo('Theme:', ["default", "blue", "green", "purple", "red", "yellow"], 
               $context.session.theme, 
               :name => 'theme') { |theme|

          unless theme == 'default'
            s = load_styles("theme/#{theme}_theme.rb")
            context['preview'].apply_styles s
          end

        }

      next_row
      section 'Preview'
        panel(:name => 'preview') {
          input "Label", "Input"
          combo ['Combo']
          button "Button"
        }

      next_row
        command(:ok, :cancel) {
      
          @target = target
          
          def on_ok

            theme = context[:theme].value

            unless theme == 'default'
              s = load_styles("theme/#{theme}_theme.rb")
              @target.apply_styles s
              $context.session.theme = theme
              $context.session.styles = s
            end
          
            context.close
            
          end
      
        }
      
    }
    
    visible true
    
  }

end

title "Banking System"

width 500
height 300

content(:layout => :border) {
  section nil, :layout => :stacked, :vgap => 10, :hgap => 10
    button("Accounts [#{Account.count_from_accounts}]") {
      $context.goto "account/list.rb"
    }
    button("Transfers [#{Transfer.count}]") {
      $context.goto "transfer/list.rb"
    }
    bottom
      align :right
      hover_label('settings') {
        open_settings $context
      }
}

$context.session.theme = 'default'
$context.start