#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

#
# Simple description of the metadata. Metadata is called ID3 TAG. There are several version of the ID3.
#
# We don't support all of them, see below for which one are supported.
#
# ID3v1
#  At the end of a MP3 an audio file can contain a fix-side 128-byte tag.
#  The first 3 characters of the 128-byte tag are 'TAG', the following bytes
#  have a predifined size and meaning (see the code, search for 'unpack')
#
# ID3v2
#   Starts with a TAG which has a header part and a body part
#
#   First 10 bytes are the header, must start with ID3 followed by 7 bytes (version, tag size)
#   After the 10 bytes come a sequence of frames, each frame starts with a name (4 characters),
#   followed by frame value length (4 bytes), flags (2 bytes) and the value. When the name is
#   only 0000 body part is finished.
#
#   TPE1 => artist
#   TIT2 => song title
#   TYER => year of recording (always 4 characters long)
#   TRCK => track number (the track number as string, could be track-number '/' total-number-of-tracks)
#   TCON => content type, genre (the genre as plain text or '(' genre-id ')')
#

require 'yaml'
  
def tail file, offset
  
  file.seek -offset, IO::SEEK_END
  
  file.read
  
end

class ID3Metadata
  
  attr_reader :file_name
  attr_reader :title, :artist, :album, :year, :comment, :genre, :track
  
  def initialize file_name
    
    @file_name = file_name
    
    f = File.new(file_name)
    
    magic_number = f.read(3)
    
    if magic_number == 'ID3'
      @title,@artist,@album,@year,@comment,@genre = ID3v2Loader.load(f, file_name)
    else
      @title,@artist,@album,@year,@comment,@genre = ID3v1Loader.load(f, file_name)
    end
    
  end
  
  def has_metadata?
    ! @title.nil?
  end
  
  def to_s
    
    if has_metadata?
      "#{@file_name}: #{@track} - #{@title} / #{@album} (#{(@year.nil? or @year.length == 0) ? "n/a" : @year}) / #{@genre}"
    else
      "#{@file_name}: no metadata"
    end
    
  end
  
  class ID3v1Loader
    
    @@genres = YAML::load(File.read('genres.yaml'))
    
    def self.load file, file_name
      
      tag,title,artist,album,year,comment,genre = tail(file, 128).unpack "A3A30A30A30A4A30C"
      
      if tag != 'TAG'
        title = artist = album = year = comment = genre = nil
      else
        
        comment, flag, track = comment.unpack "A28CC"
        
        if flag == 0 and track != 0
          comment = comment
          track = track
        end
        
        genre = @@genres[genre]
        genre = "Unknown" unless genre
        
      end
      
      return title,artist,album,year,comment,genre
      
    end
    
  end
  
  class ID3v2Loader
    
    def self.load file, file_name

      file.seek 6, IO::SEEK_SET
      
      metadata_size = convert_tag_size(file.read(4))
      
      frames = {}
      
      while file.pos < metadata_size
      
        name = file.read(4)
        
        break if name[0] == 0
        
        size = file.read(4).reverse.unpack('V')[0]
        
        file.read(2) # skip flags
      
        value = file.read(size)

        frames[name] = value[1..-1]
      
      end
      
      frames
      
      return metadata(frames)
      
    end
    
    def self.convert_tag_size x # strange_string_size
      (x[3] & 0x7F) + ((x[2] & 0x7F) << 7) + ((x[1] & 0x7F) << 14) + ((x[0] & 0x7F) << 21)
    end
    
    def self.metadata frames
      
      album = frames['TALB']
      artist = frames['TPE1']
      title = frames['TIT2']
      year = frames['TORY'] or frames['TYER']
      genre = frames['TCON']
      track = frames['TRCK']
      
      comment = nil
      
      return title,artist,album,year,comment,genre
      
    end
    
  end
  
end

if $0 == __FILE__
  
  ARGV.each do |arg|
    
    if File.directory?(arg)
      
      Dir["#{File.expand_path(arg)}/*.mp3"].each do |mp3_file|
        puts ID3Metadata.new(mp3_file)
      end
      
    else
      puts ID3Metadata.new(arg)
    end

  end
  
end