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

=begin
MVC injects @field in the view, but when some components uses the setter/getter methods to
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

