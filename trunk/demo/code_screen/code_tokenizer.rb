#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class CodeTokenizer
  
  def self.create file
    
    tokenizer = nil
    
    @@tokenizers.each do|tokenizer_class|
      
      if tokenizer_class.parses?(file)
        tokenizer = tokenizer_class.new(file)
        break
      end
      
    end
    
    tokenizer
    
  end
  
  def self.parses? file
    false
  end
  
  @@tokenizers = []
  
  def self.inherited child_class
    @@tokenizers << child_class
  end
  
  def initialize file
    @file = file
  end
  
  def tokenized_code
    
    content = load_file
    
    create_tokenizer(content)

    tokens = split_to_tokens

  end
  
  protected
  
  def load_file
    File.open(@file, "r") {|f| f.read}
  end
  
end