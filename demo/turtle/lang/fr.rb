#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class Turtle
  
  THEMES[:nb] = THEMES[:bw]
  THEMES[:rouge] = THEMES[:red]
  THEMES[:bleu] = THEMES[:blue]
  THEMES[:jaune] = THEMES[:yellow]
  
  SHORTCUTS.merge!({:ne => :netoyerecran, :mt => :montrertortue, :ct => :cachertortue, :at => :avant, :ae => :arriere, :de => :droite, :ge => :gauche})
  
  alias :en_name_for_to? :name_for_to?
  
  def name_for_to? symbol
    symbol == :pour || en_name_for_to?(symbol)
  end
  
  def netoyerecran
    clearscreen
  end
  
  def avant *args
    forward *args
  end

  def arriere *args
    back *args
  end
  
  def droite *args
    right *args
  end

  def gauche *args
    left *args
  end
  
  def lever
    up
  end
  
  def abaisser
    down
  end
  
  def montrertortue
    showturtle
  end
  
  def cacherturtle
    hideturtle
  end
  
  def repeter n
    n.times {yield}
  end
  
end
