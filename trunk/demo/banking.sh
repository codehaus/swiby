#!/bin/sh

cd banking
jruby -I../../core/lib ../../core/lib/swiby/sweb.rb banking.rb
cd ..