#!/bin/sh
cd image_viewer
jruby -I../../core/lib image_viewer.rb ../images
cd ..