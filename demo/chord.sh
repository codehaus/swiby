#!/bin/sh

cd chord
jruby -I../../core/lib chord_translator_ui.rb
cd ..