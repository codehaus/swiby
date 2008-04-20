#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

module Swiby
    
  class TabExtension < Extension
    include ComponentExtension
  end

  class TabbedPane < SwingBase

    container :tabs

    swing_attr_writer :tabPlacement, :selectedIndex, :tabLayout => :tabLayoutPolicy

    def initialize
      @component = JTabbedPane.new
    end

    def addComponents(array)

      @component.remove_all

      if array.is_a? IncrementalValue

        array.assign_to self, :addComponents

        return

      end

      if array.respond_to? :each

        array.each do |comp|
          @component.addTab comp.title, nil, comp.java_component, comp.tooltip
        end

      else
        @component.addTab array.title, nil, array.java_component, array.tooltip
      end

    end

  end

  class Tab < SwingBase

    def title=(t)
      @title = t
    end

    def title(t = nil)
      return @title if t.nil?
      self.title = t
    end

    def tooltip=(t)
      @tooltip = t
    end

    def tooltip(t = nil)
      return @tooltip if t.nil?
      self.tooltip = t
    end

    def initialize
      @component = JPanel.new
    end

  end

end
