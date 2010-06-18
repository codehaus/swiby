#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'yaml'
  
def tail file, offset
  
  f = File.new(file)
  
  f.seek -offset, IO::SEEK_END
  
  f.read
  
end

class ID3Metadata
  
  attr_reader :file_name
  attr_reader :title, :artist, :album, :year, :comment, :genre, :track
  
  @@genres = YAML::load(File.read('genres.yaml'))
    
  def initialize file_name
    
    @file_name = file_name
    
    tag,@title,@artist,@album,@year,@comment,@genre = tail(file_name, 128).unpack "A3A30A30A30A4A30C"
    
    if tag != 'TAG'
      @title = @artist = @album = @year = @comment = @genre = nil
      return
    end
    
    comment, flag, track = @comment.unpack "A28CC"
    
    if flag == 0 and track != 0
      @comment = comment
      @track = track
    end
    
    @genre = @@genres[@genre]
    @genre = "Unknown" unless @genre

  end
  
  def has_metadata?
    ! @title.nil?
  end
  
  def to_s
    
    if has_metadata?
      "#{@file_name}: #{@track} - #{@title} / #{@album} (#{@year.length == 0 ? "n/a" : @year}) / #{@genre}"
    else
      "#{@file_name}: no metadata"
    end
    
  end
  
end

if $0 == __FILE__
  
  ARGV.each do |arg|
    
    if File.directory?(arg)
      
      Dir["#{arg}/*.{mp3}"].each do |mp3_file|
        puts ID3Metadata.new(mp3_file)
      end
      
    else
      puts ID3Metadata.new(arg)
    end

  end
  
end