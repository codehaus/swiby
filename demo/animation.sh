#!/bin/sh

cd animation
jruby -I../../core/lib smiley_player.rb sad2happy.smiley
cd ..