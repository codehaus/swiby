#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby

  class ComponentOptions

    def initialize name, context
      @name = name
      @context = context
      @options = {}
      @metadata = {}
      @overloadings = []
      @valid_props = [:more_options]
    end

    def context()
      @context
    end
    
    def self.bad_signature *actual_types
      "Cannot resolve initialization signature: #{actual_types.join(', ')}"
    end
    
    def self.missing_option option_name_symbol
      "Option '#{option_name_symbol}' was not set"
    end
    
    def self.invalid_argument option_name_symbol, options, valid_types
      "Invalid argument '#{option_name_symbol}'" + 
      " type was #{options[option_name_symbol].class}" + 
      " valid types are #{valid_types.join(', ')}"
    end

    def [](key)
      @options[key]
    end

    def []=(key, value)

      if not @valid_props.include?(key)
        raise "[#{@name}] Invalid property '#{key}' (of type #{key.class}). " \
        "Valid set is #{@valid_props.join(', ')}"
      end

      @options[key] = value

    end

    def <<(props)

      return if props.nil?

      props.each do |key, value|
        self[key] = value
      end

    end

    def to_s
      @options.to_s
    end

    def method_missing(meth, *args)

      raise "[#{@name}] Missing value for property '#{meth}'" if args.length == 0
      raise "[#{@name}] Property '#{meth}' expects only one value but was #{args.length}" if args.length > 1

      self[meth] = args[0]

    end

    attr_accessor :metadata, :valid_props, :overloadings

    protected
    
    def self.define name, &block

      init = proc do
        %{
        def initialize *args, &block

          super "#{name}", args.shift
        
          self.class.setup_definition self
        
          initialize_options *args, &block

        end
        }
      end

      class_eval init.call

      work = ComponentOptions.new(nil, "Dummy")
      
      work.instance_eval(&block)

      def self.setup_definition instance
        instance.metadata = @metadata
        instance.valid_props = @valid_props
        instance.overloadings = @overloadings
      end
      
      def self.register_definition defn
        
        @metadata = defn.metadata
        @valid_props = defn.valid_props
        @overloadings = defn.overloadings
      
        # as sort is stable, we can use it because the overloading declaration order is important 
        @overloadings.reverse!.sort! do |a, b|
          a.length <=> b.length
        end
        
      end
    
      register_definition(work)
    
    end
    
    def declare name, types, optional = false
      
      optional = optional == true
      
      @valid_props << name
      
      @metadata[name] = Declaration.new(name, types, optional)
      
    end
    
    def overload *arg_list
      @overloadings += [arg_list]
    end
    
    private

    def initialize_options *args, &block
      
      while args.length > 0 and args.last.nil?
        args.pop
      end

      block_contains_options = false
      
      if args.last == :more_options
        block_contains_options = true
        args.pop
      end
      
      hash = prepare(args)
      
      self << hash unless hash.nil?
      
      if (!hash.nil? and hash[:more_options]) or block_contains_options
        instance_eval(&block) unless block.nil?
      else
        @options[:action] = block unless block.nil?
      end
      
      validate
      
    end
    
    def prepare args
      
      @overloadings.reverse_each do |signature|
        
        if args.length == signature.length or 
           (signature.length + 1 == args.length and args.last.instance_of?(Hash))
          
          i = 0
          
          signature.each do |sym|
            
            break if !@metadata[sym].compatible?(args[i])
            
            i += 1
            
          end
  
          if i == signature.length
            
            i = 0
            
            signature.each do |sym|

              @options[sym] = args[i]

              i += 1

            end
            
            return args.length > signature.length ? args.last : nil
            
          end
      
        end
        
      end
      
      if args.length == 1 && args[0].instance_of?(Hash)
        return args[0]
      end
      
      if args.length > 0
        
        types = args.collect { |arg| arg.class }
        
        raise ArgumentError.new(ComponentOptions.bad_signature(types))
        
      end 
      
      {:more_options => true}
      
    end

    def validate
      
      @metadata.each do |key, value|
        
        if @options[key].nil?
          raise ArgumentError.new(ComponentOptions.missing_option(key)) unless value.optional?
        elsif !@metadata[key].compatible?(@options[key])
          raise ArgumentError.new(ComponentOptions.invalid_argument(key, @options, @metadata[key].types))
        end
        
      end
      
    end
    
    class Declaration
      
      def initialize name, types, optional
        @name = name
        @types = types
        @optional = optional
      end
      
      def optional?
        @optional
      end
      
      def types
        @types
      end
      
      def compatible? value
        
        @types.each do |type|
          return true if value.nil? or value.kind_of?(type)
        end

        return false
        
      end
      
    end

  end

  def self.component_factory(method) #TODO find a better name like create_method...something
    class_name = ""
    code = Proc.new do
      %{
      def #{method}(*args, &block)

        x = args.length == 0 ? ::#{class_name}.new : ::#{class_name}.new(*args)

        local_context = self

        x.instance_eval do

          @local_context = local_context

          def context()
            @local_context
          end

        end

        x.instance_eval(&block) unless block.nil?

        x

      end
      }
    end

    if method.is_a? Symbol or method.is_a? String
      class_name = method.to_s.capitalize
      eval code.call
    elsif method.is_a? Hash
      method.each do |method, class_name|
        eval code.call
      end
    else
      raise RuntimeError, "#{method} should be a Symbol or a Hash"
    end
  end
  
  class IncrementalValue

    IGNORE = %w[Array Bignum Comparable Config Class Dir Enumerable ENV ERB Swiby Fixnum Float Hash
					IO Integer Kernel OptionParser Module Object Range Regexp String
					Time].map{|x| Regexp.new(x)} + [/REXML::/]

    def initialize(model, getter = nil, setter = nil, updater = nil)

      @is_updater_block = false

      if model.instance_of? Proc
        @block = model
      else

        @model = model
        @getter = getter

        if setter.nil?
          @setter = "#{getter}=".to_sym
        elsif setter.instance_of? Proc
          @setter = "#{getter}=".to_sym
          @is_updater_block = true
          @block = setter
        else
          @setter = setter
        end

        unless updater.nil?
          @is_updater_block = true
          @block = updater
        end

        add_setter_observer_to @model, @setter.to_s

      end

    end

    def validate_as_field_binding
      raise "Bound value cannot be a block" if not @block.nil?
    end

    def get_value

      if @is_updater_block
        res = @block.call(@model)
      elsif @block

        capture
        res = @block.call
        set_trace_func nil

      else
        res = @model.send @getter
      end

      res

    end

    def assign_to target, setter

      res = get_value

      @target = target
      @target_setter = setter

      @target.send @target_setter, res

    end

    def block
      @block
    end

    def replaceBlock(&b)
      @block = b
    end

    def change new_value

      if @model
        @model.send @setter, new_value
      end

    end

    def changed

      return if @target.nil?

      if @is_updater_block
        new_value = @block.call(@model)
      elsif @block
        new_value = @block.call
      else
        new_value = @model.send @getter
      end

      @target.send @target_setter, new_value

    end

    private

    def capture

      set_trace_func lambda { |event, file, line, id, binding, classname|

        case event
        when 'call', 'c-call'
          if not IGNORE.any?{|re| re =~ classname.to_s }

            binding = eval("self", binding)

            instance_var = '@' + id.to_s

            if binding.instance_variables.include?(instance_var) and binding.send(id).is_a? Array
              #TODO also observe ([], last, first, ...)
              #puts "add_observer: #{binding}.#{id} => delete_at"
              #add_modifier_observer_to binding.send(id), "delete_at"
            end

            if binding.respond_to? "#{id}="
              puts "add_observer: #{binding} => #{id}"
              add_setter_observer_to binding, "#{id}="
            end
          end
        end

      }

    end

    def add_setter_observer_to obj, setter

      #TODO must check if getter and setter (instance_variable_defined?(:@x))

      observersSym = "observers_#{setter}"[0...-1].to_sym
      real_setter = "real_setter_#{setter}"[0...-1]

      add_observer_to obj, setter, observersSym, real_setter

    end

    def add_observer_to obj, method, observersSym, alias_name

      if obj.respond_to? observersSym
        observers = obj.send(observersSym)
        observers << self if not observers.include? self
        return
      end

      #TODO remove observers

      eval %{

      class << obj

        alias_method :#{alias_name}, :#{method}

        def #{observersSym}

          @#{observersSym} = [] if @#{observersSym}.nil?

          @#{observersSym}

        end

        def #{method}(value)

          #{alias_name} value

          if @#{observersSym}
            @#{observersSym}.each do |observer|
              observer.changed
            end
          end

        end

      end

      }

      obj.send(observersSym) << self

    end

  end

  def add_array_observers array, observer
    #TODO also observe (delete, delete_at, delete_if, <<, []=, push, pop, insert, shift, replace, uniq!, sort!, compact!, collect!)
    #     << and []= cannot be used as is to build the observers collection name and alias name
    #     how to limit them? so much method changes the array object

    [:delete_at, :push].each do |method|

      observersSym = "array_observers_#{method}".to_sym
      alias_name = "real_#{method}"

      if array.respond_to? observersSym
        observers = array.send(observersSym)
        observers << observer if not observers.include? observer
        return
      end

      puts "add_observer: #{array} => #{method}"

      #TODO remove observers

      eval %{

      class << array

        alias_method :#{alias_name}, :#{method}

        def #{observersSym}

          @#{observersSym} = [] if @#{observersSym}.nil?

          @#{observersSym}

        end

        def #{method}(value)

          #{alias_name} value

          if @#{observersSym}
            @#{observersSym}.each do |observer|
              observer.#{method} value
            end
          end

        end

      end

      }

      array.send(observersSym) << self

    end

  end

end