#!/bin/sh

cd turtle
jruby -I../../core/lib turtle_editor.rb examples/geometric_form.turtle
cd ..
