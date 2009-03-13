#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/component/frame'

module Swiby

  class Applet < Frame

    def initialize

      if $parent_applet.nil?

        @parent_frame = JFrame.new

        @component = JApplet.new

        @parent_frame.content_pane.add @component, CENTER

        @parent_frame.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE

      else

        @component = $parent_applet

      end

      def @component.pack
        @parent_frame.pack unless @parent_frame.nil?
      end

    end

    def title= t
    end

  end

end