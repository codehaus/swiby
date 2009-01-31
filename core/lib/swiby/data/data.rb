#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class Class
  
  # creates a nil_instance method in the current class so that a typed nil
  # object can be used.
  # Removes any method specific to this class hierachy for the nil instance, keeps
  # all the hierachy methods but the Object's ones, unless another parent class
  # is passed as keep_methods_until_parent parameter
  def define_typed_nil keep_methods_until_parent = nil
    
    nil_instance = self.new
    
    self.class.send :define_method, :nil_instance do
      nil_instance
    end
    
    self.class.send :define_method, :keep_methods_until_class do
      keep_methods_until_parent
    end
    
    singleton_class = class << self.nil_instance
      
      def method_missing(meth, *args, &block)
        nil.send(meth, *args, &block)
      end
      
      self
      
    end
    
    im = instance_methods
    im -= instance_methods(false)
    
    found_class = false
    
    stop_class = keep_methods_until_class.superclass if keep_methods_until_class
    stop_class = Object unless keep_methods_until_class
    
    parent = superclass
  
    while parent != stop_class
    
      found_class |= parent == keep_methods_until_class
      
      im -= parent.instance_methods(false)
      
      parent = parent.superclass
      
      break unless parent
      
    end
      
    raise "class #{keep_methods_until_class} is not a super class of class #{self}" unless found_class or keep_methods_until_class.nil?
    
    im.each do |meth|
      unless meth == 'class' or meth == "respond_to?"
        singleton_class.send(:undef_method, meth) unless meth =~ /\A__/
      end
    end
    
  end

end

