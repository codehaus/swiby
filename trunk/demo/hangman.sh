#!/bin/sh

cd hangman
jruby -I../../core/lib ../../core/lib/swiby/sweb.rb hangman_ui.rb
cd ..