#!/bin/sh

cd hidden_number
jruby -I../../core/lib ../../core/lib/swiby/sweb.rb hidden_number_ui.rb
cd ..