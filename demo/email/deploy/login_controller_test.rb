#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'test/unit'
require 'swiby/mvc/test'

require 'email_client'
require 'email_test_util'

class LoginControllerTest < Test::Unit::TestCase

  def setup
    
    Swiby.define_test_view(:mailbox_view)
    
    @controller = Swiby.test_controller(LoginController.new(Connection.new))
    
  end

  def test_invalid_login
    
    @controller.login = 'James'
    @controller.password = '007'
    
    @controller.ok
    
    assert ! @controller.view_was_closed?
    assert_match(/.*login error.*/, @controller.error)    
    
  end

  def test_valid_login
    
    @controller.login = 'bingo'
    @controller.password = 'pwd'
    
    @controller.ok
    
    assert @controller.view_was_closed?
    assert_equal '', @controller.error
    
  end

  def test_exit
    
    @controller.exit
    
    assert_equal '', @controller.error
    assert @controller.view_was_closed?
    assert @controller.did_exit_application?
    
  end

end
