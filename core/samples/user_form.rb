#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/form'
require 'swiby/component/text'

class User
  
  attr_accessor :first_name, :last_name, :login, :password

  def initialize login, password, first_name, last_name
    @login = login
    @password = password
    @first_name = first_name
    @last_name = last_name
  end

  def humanize
    "#{@first_name} #{@last_name}"
  end

end

bond = User.new 'james', '007', 'James', 'Bond'

user_form = form {

  title "User Form"

  width 400
  height 260

  content {
    data bond
    section "Credentials"
    input "Login", :login
    input "Password", :password
    next_row
    section "Personal Data"
    input "First Name", :first_name
    input "Last Name", :last_name
    next_row
    button("Save") {
      message_box("Save data!")
    }
    button("Cancel") {
      exit
    }
  }

}

user_form.visible = true
