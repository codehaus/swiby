
require 'test/unit'
require 'stringio'

require 'swiby/util/arguments_parser'

class ArgumentsParserTest < Test::Unit::TestCase

  def setup
    
    @parser = create_parser_for('Tester', '1.0') {
      
      accept optional, :verbose, '-v', '-verbose', :doc => 'Enable verbose mode'
      accept optional, :server_url, '-s', '--server server_url', :doc => "Full server url (expects format like\nhttp://myserver.com)"
      accept optional, :server_port, '-p', '-port port', :doc => 'Server port'
      accept optional, :host_name, '-h', '-host host_name', :doc => 'Server host name'
      accept required, :script, :doc => 'Script to run'
      accept_remaining optional, :script_args, "Arguments for the script.\nReplaces the ARGV values when the script is run."
      
      validator do |options|
        
        unless options.server_url
          reject 'You must give a server url or a host name/port' unless options.host_name    
        end
        
      end
        
      exception_on_error
      
    }
    
    @buffer = StringIO.new
    
    @parser.redirect_output @buffer
    
    ARGV.clear
    
  end
  
  def test_validator_is_called
    
    ex = assert_raise(ArgumentError) do
      options = @parser.parse ['script']
    end
    
    assert_equal 'You must give a server url or a host name/port', ex.message
    
  end
    
  def test_failure_with_unknown_switches
    
    ex = assert_raise(ArgumentError) do
      options = @parser.parse ['-s', 'http://my-site.net', '-joe']
    end
    
    assert_equal 'Unknown switch -joe', ex.message
    
  end
    
  def test_failure_when_value_is_missing_for_a_switch
    
    ex = assert_raise(ArgumentError) do
      options = @parser.parse ['-s', 'http://here.org', '-h', '-v']
    end
    
    assert_equal 'Missing value for switch -h', ex.message
    
  end
  
  def test_initializes_options
    
    options = @parser.parse ['-s', 'http://my-site.net', 'main.rb']
    
    assert_equal 'main.rb', options.script
    assert_equal 'http://my-site.net', options.server_url
    
  end
  
  def test_remaining_are_set_in_array
    
    options = @parser.parse ['-s', 'http://my-site.net', 'main.rb', 1, 2, 3]
    
    assert_equal [1, 2, 3], options.script_args
    
    assert_equal 'main.rb', options.script
    assert_equal 'http://my-site.net', options.server_url
    
  end
  
  def test_uses_ARGV_by_default
    
    ARGV << '-h'
    ARGV << 'my-server.com'
    ARGV << 'script'
    
    options = @parser.parse
    
    assert_equal 'my-server.com', options.host_name
    
  end
  
  def test_implicitly_support_version_switch
    
    @parser.parse ['-version']
    
    assert_equal "Tester version 1.0\n", @buffer.string
    
  end
  
  def test_implicitly_support_help_switch
    
    @parser.parse ['-help']
    
    lines = @buffer.string.split("\n")
    
    assert_equal 'Usage: Tester [options] script [script_args]', lines[0]
    
  end
  
  def test_implicitly_support_short_help_switch
    
    @parser.parse ['-?']
    
    lines = @buffer.string.split("\n")
    
    assert_equal 'Usage: Tester [options] script [script_args]', lines[0]
    
  end
  
  def test_flag_switch
    
    options = @parser.parse ['-verbose', '-s', 'http://my-server.com', 'script']
    
    assert options.verbose == true
    
  end
  
  def test_flag_switch_defaults_to_false
    
    options = @parser.parse ['-s', 'http://my-server.com', 'script']
    
    assert options.verbose == false
    
  end
  
  def test_long_switch_name_with_parameter_name_in_definition
    
    options = @parser.parse ['--server', 'http://my-server.com', 'script']
    
    assert_equal 'http://my-server.com', options.server_url
    
  end
  
  def test_custom_handler
    
    @parser.accept false, :more, '-m', '-more more' do |options, value|
      
      assert_equal 'hello', value
      assert_equal 'hello', options.more
      
      options.custom_handler_was_called = true
      
    end
    
    options = @parser.parse ['--server', 'http://my-server.com', '-m', 'hello', 'script']
    
    assert options.custom_handler_was_called
    
  end
  
  def test_help_output
    
    @parser.help
    
    lines = @buffer.string.split("\n")
    
    assert_equal 'Usage: Tester [options] script [script_args]', lines[0]
    assert_equal '', lines[1]
    assert_equal 'where', lines[2]
    assert_equal '    script       Script to run', lines[3]
    assert_equal '    script_args  Arguments for the script.', lines[4]
    assert_equal '                 Replaces the ARGV values when the script is run.', lines[5]
    assert_equal '', lines[6]
    assert_equal 'where options include:', lines[7]
    assert_equal '', lines[8]
    assert_equal '    -v -verbose             Enable verbose mode', lines[9]
    assert_equal '    -s --server server_url  Full server url (expects format like', lines[10]
    assert_equal '                            http://myserver.com)', lines[11]
    assert_equal '    -p -port port           Server port', lines[12]
    assert_equal '    -h -host host_name      Server host name', lines[13]
    
  end
  
end

class TestRequired < Test::Unit::TestCase

  def setup
    
    @parser = create_parser_for('Tester', '1.0') {
      
      accept optional, :verbose, '-v', '-verbose'
      accept required, :server_url, '-s', '--server server_url'
      accept required, :script, :doc => 'Script to run'
      
      exception_on_error
      
    }
    
    @parser.redirect_output StringIO.new
    
  end
  
  def test_raise_exception_if_required_argument_is_missing
    
    ex = assert_raise(ArgumentError) do
      options = @parser.parse ['-v']
    end

    assert_equal 'Missing required arguments: server_url, script', ex.message
    
  end

end

class TestSwitchesOnly < Test::Unit::TestCase

  def setup
    
    @parser = create_parser_for('Tester', '1.0') {
      
      accept optional, :verbose, '-v', '-verbose'
      accept required, :server_url, '-s', '--server server_url'
      
      exception_on_error
      
    }
    
    @parser.redirect_output StringIO.new
    
  end
  
  def test_error_argument_without_its_switch
    
    ex = assert_raise(ArgumentError) do
      @parser.parse ['-s', 'here', 'there']
    end
    
    assert_equal "Unexpected argument: there", ex.message
    
  end

end