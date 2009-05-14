#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'

require 'open-uri'

def open url
  yield Swiby::DummyHTTP.open(url)
end

def http_error status
  
  o = OpenStruct.new

  o.status = status

  return OpenURI::HTTPError.new("Simulate #{status} error", o)

end

require 'tmpdir'
require 'pathname'
require 'ostruct'
require 'socket'

require 'swiby/util/simple_cache'

module Swiby
  
module CacheTestHelper end

class TestNewCache < Test::Unit::TestCase

  include CacheTestHelper
  
  def setup
    initialize_cache
  end
  
  def test_resolve_existing_file
    
    DummyHTTP.add('http://my.com/app/hello.rb', nil, 1)
    
    local = @cache.from_cache('hello.rb')
    
    assert_equal @dir + '/my.com/app/hello.rb', local
    
  end
  
  def test_file_not_found
    
    local = @cache.from_cache('hello.rb')
    
    assert_nil local
    
  end

  def test_accesses_remote_first_time_only
    
    DummyHTTP.add('http://my.com/app/hello.rb', nil, 1)
    
    local = @cache.from_cache('hello.rb')
    local = @cache.from_cache('hello.rb')
    
    assert_equal @dir + '/my.com/app/hello.rb', local
    
  end
  
  def test_cached_files_are_in_cache_dir
    
    DummyHTTP.add('http://my.com/app/hello.rb', nil, 1, "abcd")
    
    local = @cache.from_cache('hello.rb')
    
    content = File.open(local) do |f|
      f.read
    end
    
    assert_equal "abcd", content
    
  end
  
  def test_clear_cache
    
    DummyHTTP.add('http://my.com/app/hello.rb', nil, 1, "abcd")
    
    local = @cache.from_cache('hello.rb')
    
    @cache.clear
    
    assert File.exist?(@dir)
    assert !File.exist?(local)
    
    # empty directories contain 2 entries: .. and .
    assert_equal 2, Dir.entries(@dir + '/my.com').length
    
  end

  def test_once_accessed_does_not_reload
    
    DummyHTTP.add('http://my.com/app/hello.rb', Time.parse('15:00'), 1, "abcd")
    
    @cache.from_cache('hello.rb')
    
    DummyHTTP.add('http://my.com/app/hello.rb', Time.parse('16:00'), 1, "xyz")
    
    cached_file('hello.rb').should_contain "abcd"

  end

  def test_forgets_access_history_when_closed
    
    DummyHTTP.add('http://my.com/app/hello.rb', nil, 2)
    
    @cache.from_cache('hello.rb')
    
    @cache.close
    
    @cache.from_cache('hello.rb')
    
    assert_equal 0, DummyHTTP['http://my.com/app/hello.rb'].expected_access
    
  end
  
  def test_close_saves_cache_metadata
    
    DummyHTTP.add('http://my.com/app/hello.rb', nil, 1)
    
    @cache.from_cache('hello.rb')
    
    @cache.close
    
    expected = @dir + '/my.com/app/data.yml'
    assert File.exist?(expected), "#{expected} YAML file should exist"
    
  end
  
end

class TestExistingCache < Test::Unit::TestCase

  include CacheTestHelper
  
  def setup
    prepare_cache
  end
  
  def test_reuse_cache_when_reopen
    
    DummyHTTP.add('http://my.com/app/hello.rb', Time.parse('15:00'), 1, "wxyz")
    
    cached_file('hello.rb').should_contain "abcd"
    
  end
  
  def test_reloads_changed_file_when_reopen_cache
    
    DummyHTTP.add('http://my.com/app/hello.rb', Time.parse('16:00'), 1, "wxyz")
    
    cached_file('hello.rb').should_contain "wxyz"
    
  end
  
  def test_access_file_in_cache_when_offline

    DummyHTTP.offline = true
    
    cached_file('hello.rb').should_contain "abcd"

  end
  
  def test_access_file_in_cache_when_remote_server_error
    
    DummyHTTP.add('http://my.com/app/hello.rb', nil, 1, "xyz", http_error("500"))
    
    cached_file('hello.rb').should_contain "abcd"
    
  end
  
  def test_file_not_in_cache_when_offline
    
    DummyHTTP.offline = true
    
    assert_nil @cache.from_cache('ha.rb')
    
  end
  
  def prepare_cache
    
    initialize_cache

    # prepare/create cache
    DummyHTTP.add('http://my.com/app/hello.rb', Time.parse('15:00'), 1, "abcd")
    @cache.from_cache('hello.rb')
    @cache.close
    
    # reopen the cache
    @cache = SimpleCache.new('http://my.com/app', @dir, false)
    
  end
  
end

module CacheTestHelper
  
  def teardown
    
    DummyHTTP.clear
    
    p = Pathname.new(@dir)
    p.rmtree if p.exist?
    
    raise "Cannot delete the test dir #{p}" if p.exist?
    
  end
  
  def initialize_cache
    @dir = Dir.tmpdir + '/swiby_tests_tmp'
    @cache = SimpleCache.new('http://my.com/app', @dir, false)
  end
  
  def cached_file file
    
    o = OpenStruct.new
    
    o.test = self
    o.file = file
    o.cache = @cache
    
    def o.should_contain expected
      
      local = self.cache.from_cache(self.file)

      content = File.open(local) do |f|
        f.read
      end

      self.test.assert_equal expected, content
      
    end
    
    o
    
  end
  
end

class DummyHTTP
    
  attr_accessor :last_modified, :expected_access, :content, :exception

  def self.add url, last_modified, expected_access, content = nil, ex = nil
    @@content[url] = DummyHTTP.new(last_modified, expected_access, content, ex)
  end
  
  def self.clear
    @@content.clear
    @@offline = false
  end

  def self.offline= flag
    @@offline = flag
  end
  
  def self.[] url
    @@content[url]
  end
  
  def self.open url
    
    raise SocketError.new("Simulate offline") if @@offline
      
    if @@content.key?(url)
      
      @@content[url].expected_access -= 1
      
      raise Test::Unit::AssertionFailedError.new("Unexpected call for '#{url}'") if @@content[url].expected_access < 0
      
      res = @@content[url]
      
      raise res.exception if res.exception
      
      res
      
    else
      
      raise http_error("404")
      
    end
    
  end
  
  def read
    @content
  end
  
  def initialize last_modified, expected_access, content, exception
    @last_modified = last_modified
    @expected_access = expected_access
    @content = content
    @exception = exception
  end
  
  @@content = {}
  @@offline = false
  
end

end