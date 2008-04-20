#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Kernel

  def resolve_local_file file_name
    
    $LOAD_PATH.each do |path|
      
      path = File.expand_path(file_name, path)
      
      return path if File.exist?(path)
      
    end
    
    nil
    
  end
  
end
