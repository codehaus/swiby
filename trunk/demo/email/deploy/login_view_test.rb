#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/test'

include Swiby

require 'email_client'
require 'email_test_util'

gui_test_suite('Login View') {

  window {
    Views[:login_view].instantiate(LoginController.new(Connection.new))
  }
  
  test('invalid login') {
    prepare {
      login 'unknown'
      password 'user'
      ok.click
    }
    check {
      error.should_match(/.*login error.*/)
    }
  }

  test('valid login') {
    prepare {
      login 'bingo'
      password 'pwd'
      ok.click
    }
    check {
      error.should_be_empty
      view.should_be_closed
    }
  }
  
  test('exit application') {
    prepare {
      exit_application.click
    }
    check {
      error.should_be_empty
      application.should_be_closed
    }
  }
  
}
