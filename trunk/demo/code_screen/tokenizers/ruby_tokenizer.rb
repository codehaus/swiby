require 'rdoc/rdoc'

module RubyToken

  class Token
    
    def keyword?
      self.is_a?(RubyToken::TkKW)
    end
    
    def value?
      self.is_a?(RubyToken::TkVal)
    end
    
  end
  
end

class RubyTokenizer < CodeTokenizer

  def self.parses? file
    file =~ /\.rb$/
  end
  
  def create_tokenizer content
    
    # with jRuby lexer fails for some scripts because next option is nil
    Options.instance.instance_variable_set(:@tab_width, 2)

    @tokenizer = RubyLex.new(content)
    
  end

  def split_to_tokens
    
    tokens = []

    token = @tokenizer.token

    while token
      
      tokens << token
      
      token = @tokenizer.token
      
    end

    tokens
    
    group_tokens_by_line(tokens)
    
  end

  def group_tokens_by_line tokens_in

    line = []
    tokens = []
    
    tokens_in.each do |token|
      
      if token.is_a?(RubyToken::TkNL)
        tokens << line
        line = []
      else
        line << token
      end
      
    end
    
    tokens
    
  end
  
end
