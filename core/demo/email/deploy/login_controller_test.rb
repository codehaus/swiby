
require 'test/unit'
require 'swiby/mvc/test'

require 'email_client'

class Connection
  def last_error
    {:message => 'login error'}
  end
end

class Auth
  
  def initialize connection
  end
  
  def logIn login, password
    login == 'bingo' and password == 'pwd'
  end
  
end

class Inbox
  
  def initialize connection
  end
  
end

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
