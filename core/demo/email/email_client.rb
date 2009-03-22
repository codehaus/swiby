#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'time'

require 'pretty_time'

require 'email_views'
require 'email_remote'

class LoginController

  def initialize
    @error_message = ''
  end
  
  def login= login
    @login = login
  end
  
  def password= password
    @password = password
  end
  
  def ok
    
    auth = Auth.new(Connection.new)
    
    unless auth.login(@login, @password)
      @error_message = "<html><font color='red'>#{auth.last_error[:message]}</font>"
    else
      Views[:mailbox_view].instantiate(MailboxController.new(auth))
      @window.close
    end
    
  end
  
  def exit
    @window.exit
  end
  
  def error
    @error_message
  end
  
end

class MailboxController
  
  def initialize auth
    @auth = auth
    @box = @auth.inbox
  end
  
  def current_mailbox_content= index
    @current = index
  end
  
  def mailbox_content_changed?
    @messages.nil?
  end
  
  def mailbox_content
    @messages = format_messages(@box.messages)
  end
  
  def detail
    
    if @current
      message = @messages[@current]
      "From: #{message[:from]}\nSubject: #{message[:subject]}\n\n#{message[:message]}"
    end
  
  end

  def reply
    
    message = @messages[@current]
    
    subject = "Re: #{message[:subject]}"
    body = "\n====================\n#{message[:message]}"
    
    Views[:mail_composer].instantiate(MailComposerController.new(@auth, message[:from], subject, body))
    
  end
  
  def may_reply?
    not @current.nil?
  end
  
  def new_mail
    Views[:mail_composer].instantiate(MailComposerController.new(@auth))
  end
  
  private
  
  def format_messages messages
    
    messages.each do |message|
      message[:sentTime] = format_pretty_time(message[:sentTime])
    end
    
    messages
    
  end
  
end

class MailComposerController
  
  attr_accessor :recipient, :subject, :body
  
  def initialize auth, recipient = nil, subject = nil, body = nil
    @auth, @recipient, @subject, @body = auth, recipient, subject, body
  end
  
  def cancel
    @window.close
  end
  
  def send_mail
    @auth.sentbox.send @subject, @body, @recipient
    @window.close
  end
  
  def may_send_mail?
    not @recipient.nil? and @recipient.strip.length > 0
  end
  
end

Views[:login_view].instantiate(LoginController.new)
