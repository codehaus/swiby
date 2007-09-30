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

require 'java'

module F3

  include_class 'javax.swing.JScrollPane'
    
	class SwingBase
		
		def self.swing_attr_accessor(symbol, *args)
			
			map, err = to_map(symbol, args)
			
			raise RuntimeError, err if not err.nil?

			generate_swing_attribute map, true
			
		end
		
		def self.swing_attr_writer(symbol, *args)
			
			map, err = to_map(symbol, args)
			
			raise RuntimeError, err if not err.nil?

			generate_swing_attribute map, false
			
		end
		
		def self.container(symbol)
		
			raise RuntimeError, "#{symbol} is not a Symbol" if not symbol.is_a? Symbol
			
			eval %{
				
				def #{symbol}(array = nil, &block)
				
					if array.nil?
						self.addComponents block.call
					else
						self.addComponents array
					end
					
				end
			
			}
			
		end
	
		def scrollable
			@scroll_pane = JScrollPane.new @component
		end
	
		def install_listener iv
		end
		
		def java_component
			
			if @scroll_pane.nil?
				@component
			else
				@scroll_pane
			end
			
		end
		
		#TODO remove private because some calls to 'addComponents' were forbidden (with JRuby 1.0.1)
		#private
		
		def self.to_map(symbol, args)
		
			map = Hash.new
			
			err = fill_map map, symbol
			
			return nil, err if not err.nil?
			
			return map, nil if args.nil?
			
			args.each do |sym|
			
				err = fill_map map, sym
				
				return nil, err if not err.nil?
				
			end
			
			return map, nil
			
		end
		
		def self.fill_map(map, x)
		
			if x.is_a? Hash
			
				x.each do |k, v|
				
					return "#{k} must be a Symbol" if not k.is_a? Symbol
				
					map[k] = v
					
				end
				
			elsif x.is_a? Symbol
				map[x] = nil
			else
				return "#{x} must be a Symbol"
			end
			
			nil
			
		end
		
		def self.generate_swing_attribute(map, both)
			
			map.each do |symbol, javaName|
			
				javaName = symbol if javaName.nil?
			
				if both
				
					class_eval %{
						
						def #{symbol}
							@component.#{javaName}
						end
						
					}

				end
				
				class_eval %{
					
					def #{symbol}=(val)
						@component.#{javaName} = val
					end
					
					def #{symbol}(val = nil, &block)
						
						if val.instance_of? IncrementalValue
						
							val.assign_to self, :#{symbol}=
							
							install_listener val
							
						else
						
							if val.nil?
								val = block.call if not block.nil?
							end
				
							self.#{symbol} = val
							
						end
						
					end
					
				}
				
			end
	
		end
		
		def addComponents(array)
		
			if array.respond_to? :each
		
				array.each do |comp|
					 @component.add comp.java_component
				end
				
			else
				@component.add array.java_component
			end
			
		end
		
	end
		
	def self.component_factory(method)
	
		class_name = ""
		
		code = Proc.new do 
			%{
				
				def #{method}(&block)
					x = ::#{class_name}.new
					x.instance_eval(&block)
					x
				end
				
			}
		end
	
		if method.is_a? Symbol or method.is_a? String
			
			class_name = method
			
			eval code.call
			
		elsif method.is_a? Hash
			
			method.each do |method, class_name|
				eval code.call
			end
		
		else
			raise RuntimeError, "#{method} should be a Symbol or a Hash"
		end
		
	end

end