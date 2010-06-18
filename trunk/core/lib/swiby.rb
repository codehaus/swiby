#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'java'
require 'swiby/context'

Swiby::CONTEXT.default_setup
  
include Swiby

puts "BUG [#{__FILE__}] Test failures: \input_options_test.rb - Syntax input value &options "
puts "BUG [#{__FILE__}] Test failures: \combo_test.rb / Handler receives objects"
puts "BUG [#{__FILE__}] Test failures: syntax - all in blocks (text field) / tooltip provider"
puts "TODO [#{__FILE__}] MVC slider and button have common logic, see registration_done + handles_actions?"
puts "TODO [#{__FILE__}] see unclassifed doc here..."
puts "TODO [#{__FILE__}] MVC-file console"
puts "TODO [#{__FILE__}] MVC email-demo use table but wrongly uses 'display' to refresh table's data!"
puts "TODO [#{__FILE__}] replace the need_* with use_*, seems better"
puts "TODO [#{__FILE__}] how to setup initial state? - list has no selection otherwise"
puts "TODO/BUG #{__FILE__} mvc/list.rb remove gesture problem, animation should not work anymore / maybe combo.rb - Swing::SwibyComboBoxRender should make it happen (search ImageListRemovalGesture-"
puts "TODO [#{__FILE__}] MVC: test bindable (on both view and controller)"
puts "TODO [#{__FILE__}] MVC: tests w/ controller at frame level"
puts "TODO [#{__FILE__}] MVC: what about automated tests? still running?"
puts "REFACTOR [#{__FILE__}] !! MVC should master.refresh delay refresh to avoid possible cascading calls?"
puts "REFACTOR [#{__FILE__}] !! MVC Frame should add a 'controller' attribute to plug the MVC, otherwise plug auto"
puts "REFACTOR [#{__FILE__}] should 'declare :minimum, [Fixnum], true' defaults to true or use :optional/:required"
puts "TODO [#{__FILE__}] component/radio_button.rb 'clear' removes the radio buttons but not the listener, not really necessary"
puts "TODO [#{__FILE__}] load context.cfg if exist: language, bundles, theme"
puts "TODO [#{__FILE__}] improve auto_hide hint position"
puts "TODO [#{__FILE__}] should have a module giving a default implementation of apply_styles, change_language"
puts "TODO [#{__FILE__}] add tests for strict directive in ComponentOptions"
puts "TODO [#{__FILE__}] add 'theme' concept, application level styles"
puts "TODO [#{__FILE__}] add 'intent' and 'gesture' concepts"
puts "TODO [#{__FILE__}] tooltips and sweb? (see line 124 / def refresh_tooltips in forms.rb"
puts "TODO [#{__FILE__}] syntax_test.rb part 'TextField' in 'All in blocks' displays a block.to_s!"
puts "TODO [#{__FILE__}] how could files be used with and w/out sweb"
puts "TODO [#{__FILE__}] autosize should check if there is space engough not expand beyond"
puts "TODO [#{__FILE__}] Sweb + configuration stuffs like searching for translation files"
puts "TODO [#{__FILE__}] inject something like @parent instead of context?"
puts "TODO [#{__FILE__}] styles should also support center/align right, and more..."
puts "TODO [#{__FILE__}] require File.join( File.dirname( File.expand_path(__FILE__)), 'lib', 'helpers')" # seen on http://www.untilnil.com/2009/02/25/require-principle_of_least_surprise
puts "TODO [#{__FILE__}] One reload-hook per page or per session?"
puts "TODO [#{__FILE__}] Titled-border apply styles / reload does not work"
puts "TODO [#{__FILE__}] Not all components support style_id or style_class (editor, table, etc)"
puts "TODO [#{__FILE__}] options +  style test refactoring"
puts "TODO [#{__FILE__}] What about using javax.swing.UIDefaults / see UIManager.getDefaults()"
puts "TODO [#{__FILE__}] change the builder implementation, don't use a_object.call(&builder_block)"
puts "TODO [#{__FILE__}] should console show layers? - a la photoshop?"
puts "TODO [#{__FILE__}] prepare 'demo parade' or 'demo festival' using 'Stripes' concept (flash + webstart)"
puts "TODO [#{__FILE__}]   > Use Swiby logo on main page"
puts "TODO [#{__FILE__}]   > WordPuzzle, Clock, Banking, Calculator, ImageViewer"
puts "TODO [#{__FILE__}]   > Animation, Shopper, Hidden number, Hangman, Logo, jigsaw puzzle"
puts "TODO [#{__FILE__}]   > pointage? email demo? bug tracking sytem?"
puts "TODO [#{__FILE__}]   > All manual tests? -- add a green/red/orange bar"
puts "TODO [#{__FILE__}]   (see also http://www.duncanjauncey.com/btinternet/zoomdesk/download.html / openzoom.com)"
puts "TODO [#{__FILE__}]   MigLayout, callback Dock Demo with button changing their size"
puts "TODO [#{__FILE__}] layouts (stacked) w/ imagelist too big use borderlayout approach (see next window)!"
puts "TODO [#{__FILE__}] hierachy dump display class name when ruby implements of java comp"
puts "TODO [#{__FILE__}] palette use :closeable instead of true/false?"
puts "TODO [#{__FILE__}] templates/parts for views"
puts "NICE [#{__FILE__}] turtle_editor, save script on exit + warn if not saved and open a new + undo/redo"

=begin
MVC injects @field in the view, but when some components uses the setteer/getter methods to
plug MVC behaviors it may conflicts if the view is used as controller:

  form {
    progress_bar 'Hello', :name => :hello
    
    def hello
      @hello
    end
    
    def hello= x
      @hello = x
    end
    
    def start_timer
      each(3000) {
        self.hello = (self.hello + 1).module(100)
      }
  }
  
=end

