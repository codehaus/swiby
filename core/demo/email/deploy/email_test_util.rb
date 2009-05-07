#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

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
  
  # needed for view testing
  def messages
    []
  end
  
end