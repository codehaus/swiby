#--
# BSD license
#
# Copyright (c) 2007, Jean Lazarou
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this list
# of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or other
# materials provided with the distribution.
# Neither the name of the null nor the names of its contributors may be
# used to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#++

require 'swiby_form'

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
    button "Save" do
      message_box("Save data!")
    end
    button "Cancel" do
      exit
    end
  }

}

user_form.visible = true
