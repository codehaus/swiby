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
	
	attr_reader :container
	
	def start
		@container.visible = true
	end
	
	def goto page
		@titles << @container.java_component.title #TODO must reslove problem @container.title conflicts with @container.title(x)
		@container.setup
		@history << @container.java_component.content_pane
		@history_index += 1
		load page
	end
	
	def exit
		# exit the application...
	end
	
	def back
		
		return if @history_index == 0
		
		@history_index -= 1
		@container.title @titles[@history_index]
		@container.java_component.content_pane = @history[@history_index]
		
	end
	
	def forward
		
		return unless @history_index + 1 < @history.size
		
		@history_index += 1
		@container.title @titles[@history_index]
		@container.java_component.content_pane = @history[@history_index]
		
	end
	
	def initialize
		@titles = []
		@history = []
		@container = Form.new
		@history << @container.java_component.content_pane
		@history_index = 0
	end
	
end

$context = Sweb.new

def width w
	$context.container.width w
end

def height h
	$context.container.height h
end

def title t
	$context.container.title t
end

def content &block
	$context.container.instance_eval(&block)
end
