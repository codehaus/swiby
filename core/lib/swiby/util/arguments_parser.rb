
require 'ostruct'

def create_parser_for app_name, version, &builder
  
  parser = ArgumentsParser.new(app_name, version)
  
  parser.instance_eval(&builder)
  
  parser
  
end

class ArgumentsParser

  def initialize app_name, version
    
    @app_name, @version = app_name, version
    
    @definitions = []
    @exit_on_error = true
    
    @out = $stdout
    
  end
  
  def required
    true
  end
  
  def optional
    false
  end
  
  def exit_on_error
    @exit_on_error = true
  end
  
  def exception_on_error
    @exit_on_error = false
  end
  
  def accept required, name, short_switch = nil, long_switch = nil, doc = nil, &handler
    
    definition = to_map([:name, :short, :long, :doc], name, short_switch, long_switch, doc, &handler)
    definition[:required] = required ? true : false
    definition[:has_switch] = definition[:short] or definition[:long]
    definition[:consumes] = 1 unless definition[:has_switch]
    
    if definition[:long]
      
      parts = definition[:long].split
      
      definition[:long] = parts[0]
      definition[:param_name] = parts[1]
      
    end
    
    @definitions << definition
    
  end
  
  def accept_remaining required, name, doc = nil, &handler
    
    definition = to_map([:name, :doc], name, doc, &handler)
    definition[:required] = required ? true : false
    definition[:has_switch] = false
    definition[:consumes] = -1 unless definition[:has_switch]
    
    @definitions << definition
    
  end
  
  def validator &validator
    @validator = validator
  end
    
  def parse args = ARGV
    
    options = OpenStruct.new
    
    unnamed = []
    required = {}
    
    @definitions.each do |definition|
      
      required[definition[:name]] = definition if definition[:required]
      
      unnamed << definition unless definition[:has_switch]
      
      options.send "#{definition[:name].to_s}=".to_sym, false if definition[:has_switch] and definition[:param_name].nil?
      
    end
    
    values_count = 0
    did_output_info = false
    
    waiting_for = nil
    
    args.each do |arg|
      
      if arg =~ /^-.*/

        reject "Missing value for switch #{waiting_for[:short] ? waiting_for[:short] : waiting_for[:long]}" if waiting_for
        
        definition = find(arg)
        
        unless definition
        
          if arg == '-version'
            did_output_info = true
            version
          elsif arg == '-?' or arg == '-help'
            did_output_info = true
            help
          else
            reject "Unknown switch #{arg}"
          end
          
        else
          waiting_for = nil
          
          if definition[:param_name]
            waiting_for = definition
          elsif definition[:has_switch]
            
            name = definition[:name]
            
            options.send "#{name}=".to_sym, true
            definition[:handler].call(options, true) if definition[:handler]
            
            required.delete(name)
            
          end
          
        end
        
      else
        
        if waiting_for
          
          definition = waiting_for
          
          name = waiting_for[:name]
          waiting_for = nil
          
        else
          
          definition = unnamed.first
          
          name = definition[:name]
          
          if definition[:consumes] == 1
            unnamed.shift
          else
            
            value = options.send(name)
            
            if value
              value << arg
              arg = value
            else
              arg = [arg]
            end
              
            if definition[:consumes] == arg.length
              unnamed.shift
            end
            
          end
          
        end
        
        options.send "#{name}=".to_sym, arg
        definition[:handler].call(options, arg) if definition[:handler]
        
        required.delete(name)
        
      end
      
    end
    
    if did_output_info and values_count == 0
      exit if @exit_on_error
      return nil
    end
    
    unless required.empty?
      
      missing = []
      
      required.each do |name, definition|
        missing << name
      end
      
      reject "Missing required arguments: #{missing.join(', ')}"
      
    end
  
    @validator.call(options) if @validator
    
    options
    
  end

  def redirect_output out
    @out = out
  end
  
  def reject error_cause
    
    raise ArgumentError, error_cause unless @exit_on_error
    
    @out.puts error_cause
    @out.puts
    
    help
    
    exit if @exit_on_error

  end
  
  def version
    @out.puts "#{@app_name} version #{@version}"
  end
  
  def help
    
    @out.puts usage_text
    @out.puts
    
    text = unnamed_explain_text

    @out.puts text if text
    @out.puts
    
    text = switches_explain_text

    @out.puts text if text
    
  end
  
  private
  
  def to_map *values, &handler
    
    mapped = {:handler => handler}
    
    names = values[0]
    
    values.each_index do |i|
      
      unless i == 0

        par = values[i]
        
        if par.is_a?(Hash)
          par.each {|key, value| mapped[key] = value}
          break
        else
          mapped[names[i - 1]] = par
        end

      end
  
    end
    
    mapped
    
  end
  
  def find switch
    
    @definitions.each do |definition|
      return definition if definition[:short] == switch or definition[:long] == switch
    end
    
    nil
    
  end
  
  def usage_text
    
    usage = "Usage: #{@app_name} [options]"

    @definitions.each do |d|
      
      unless d[:has_switch]
        
        name = d[:name].to_s
        
        usage << " #{d[:required] ? name : "[#{name}]"}"
        
      end
      
    end
    
    usage
    
  end
  
  def unnamed_explain_text
    
    max_len = 0

    @definitions.each do |d|
      
      unless d[:has_switch]
        
        name = d[:name].to_s
        
        max_len = max_len < name.length ? name.length : max_len
        
      end
      
    end

    where = ['where']
    
    if max_len > 0
      
      @definitions.each do |d|
        
        unless d[:has_switch]
          
          name = d[:name].to_s
          
          lines = d[:doc].split("\n")
          
          lines.each_index do |i|
            
            if i == 0
              where << "    #{name}#{' ' * (max_len - name.length)}  #{lines[i]}"
            else
              where << "    #{' ' * max_len}  #{lines[i]}"
            end
            
          end
          
        end
        
      end
      
    end
    
    where.length > 1 ? where.join("\n") : nil
    
  end

  def switches_explain_text
    
    max_len = 0
    
    @definitions.each do |d|
      
      if d[:has_switch]
        
        name = "#{d[:short]} #{d[:long]} #{d[:param_name]}"
        
        max_len = max_len < name.length ? name.length : max_len
        
      end
      
    end
    
    explain = ["where options include:\n"]
    
    if max_len > 0
      
      @definitions.each do |d|
        
        if d[:has_switch]
          
          name = "#{d[:short]} #{d[:long]} #{d[:param_name]}"
          
          lines = d[:doc].split("\n")
          
          lines.each_index do |i|
            
            if i == 0
              explain << "    #{name}#{' ' * (max_len - name.length)}  #{lines[i]}"
            else
              explain << "    #{' ' * max_len}  #{lines[i]}"
            end
            
          end
          
        end
      
      end
      
    end
    
    explain.length > 1 ? explain.join("\n") : nil
    
  end
  
end
