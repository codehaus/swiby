Usage: ruby chord_translator.rb {chord-symbols}

Example:
>ruby chord_translator.rb C Cdim7 Am F#+7
C => C E G
Cdim7 => C Eb Gb A
Am => A C E
F#+7 => F# A# D E

Or, the gui version: jruby -I<swiby-dir>/core/lib chord_translator_ui.rb

It uses a font to draw the musical symbols I downloaded from http://simplythebest.net/fonts/fonts/musical_symbols.html
Its name is "MusicalSymbols".