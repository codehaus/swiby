#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

puts "TODO [#{__FILE__}] require File.join( File.dirname( File.expand_path(__FILE__)), 'lib', 'helpers')" # seen on http://www.untilnil.com/2009/02/25/require-principle_of_least_surprise
puts "TODO [#{__FILE__}] One reload-hook per page or per session?"
puts "TODO [#{__FILE__}] Titled-border apply styles / reload does not work"
puts "TODO [#{__FILE__}] Not all components support style_id or style_class (editor, table, etc)"
puts "TODO [#{__FILE__}] options +  style test refactoring"
puts "TODO [#{__FILE__}] What about using javax.swing.UIDefaults / see UIManager.getDefaults()"
puts "TODO [#{__FILE__}] change the builder implementation, don't use a_object.call(&builder_block)"


module Swiby
  SWIBY_VERSION = '1.0'
end

require 'swiby/swing'
require "swiby_ext-#{Swiby::SWIBY_VERSION}.jar"

include Swiby
