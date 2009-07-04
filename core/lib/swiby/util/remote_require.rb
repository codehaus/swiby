#-- 
#  Copyright (C) Swiby Committers. All rights reserved.
#  
#  The software in this package is published under the terms of the BSD
#  style license a copy of which has been included with this distribution in
#  the LICENSE.txt file.
# 
#++
  
require 'swiby/util/remote_loader'

module Kernel

  # alias the orginal require/load
  alias swiby_sys_require require
  alias swiby_sys_load load
  
  def require file_name
    swiby_sys_require to_local_file(file_name)
  end

  def load file_name
    swiby_sys_load to_local_file(file_name)
  end
  
  def to_local_file file_name

    if not Swiby::exclude_remote?(file_name)
      
      #puts "remote #{file_name}" #TODO in 'debug' mode should log this...

      cached = Swiby::RemoteLoader.from_cache(file_name)
    
      unless cached
        cached = Swiby::RemoteLoader.from_cache(file_name + ".rb") if not Swiby::script?(file_name)
      end
      
      file_name = cached if cached
      
    end
    
    file_name
    
  end
  
end
