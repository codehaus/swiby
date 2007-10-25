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

class Sweb
	
  attr_accessor :source
	attr_reader :container, :top_container
	
	def start
		@top_container.visible = true
	end
	
	def goto page
		
    @container = form(:as_panel)
		@history << @container
    @sources << page
		@history_index += 1
		load page
		
    self.source = page
    
    @top_container.java_component.content_pane.remove 1
    @top_container.java_component.content_pane.add @container.java_component
		@top_container.java_component.validate
    
	end
	
	def exit
		# exit the application...
	end
	
	def back
		
		return if first_page?
		
		@history_index -= 1
    @container = @history[@history_index]
		@top_container.title @titles[@history_index]
    @top_container.java_component.content_pane.remove 1
		@top_container.java_component.content_pane.add @container.java_component
		@top_container.java_component.content_pane.validate
    @top_container.java_component.repaint
		
    self.source = @sources[@history_index]
    
	end
	
	def forward
		
		return if last_page?
		
		@history_index += 1
    @container = @history[@history_index]
		@top_container.title @titles[@history_index]
    @top_container.java_component.content_pane.remove 1
		@top_container.java_component.content_pane.add @container.java_component
		@top_container.java_component.validate
    @top_container.java_component.repaint
		
    self.source = @sources[@history_index]
    
	end
	
	def first_page?
		@history_index == 0
	end
	
	def last_page?
    @history_index + 1 >= @history.size
	end
  
	def register_title t
		@top_container.title t
		@titles[@history_index] = t
	end
	
	def initialize
		
		@history_index = 0
    
    @titles = []
    @sources = []
		@history = []
    
    @source = $0
    
    @container = form(:as_panel)
    
		@top_container = frame do
      
      toolbar do
        button do
          icon "swiby/images/go-previous.png"
          enabled bind(context, :source) {|context| not context.first_page?}
          action proc {$context.back}
        end
        button create_icon("swiby/images/go-next.png"), :more_options do
          enabled bind(context, :source) {|context| not context.last_page?}
          action proc {$context.forward}
        end
      end
      
      toolbar do
        input bind(context, :source)
      end

    end
    
    @top_container.java_component.content_pane.add @container.java_component
		
    @history << @container
		@titles << ""
    @sources << @source
    
	end
	
end

$context = Sweb.new

def width w
	$context.container.width w if $context.first_page?
end

def height h
	$context.container.height h if $context.first_page?
end

def title t
	$context.register_title t
end

def content &block
	$context.container.instance_eval(&block)
end
