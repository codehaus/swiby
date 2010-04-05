#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

class Shopper
  
  def initialize
    @products = {}
  end
  
  def << product
    @products[product] = product
  end
  
  def remove product
    @products.delete(product)
  end
  
  def contain? product
    not @products[product].nil?
  end
  
end
