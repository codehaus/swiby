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

  # alias the orginal require
  alias sys_require require
  
  #TODO must do the same thing for 'load', with reload if file changed
  def require file_name

    if not Swiby::exclude_remote?(file_name)
      
      puts "remote require #{file_name}" #TODO in 'debug' mode should log this...

      cached = Swiby::RemoteLoader.from_cache(file_name)
    
      unless cached
        cached = Swiby::RemoteLoader.from_cache(file_name + ".rb") if not Swiby::script?(file_name)
      end
      
      file_name = cached if cached
      
    end

    sys_require file_name

  end

end
