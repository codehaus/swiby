#--
# Copyright (C) Swiby Committers. All rights reserved.
#
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'miglayout-3.6.3-swing.jar'

import 'net.miginfocom.swing.MigLayout'

require 'swiby/layout_factory'

module Swiby

  class GridFactory

    def accept name
      name == :grid
    end

    def create name, data

      hgap = data[:hgap] ? data[:hgap] : 0
      vgap = data[:vgap] ? data[:vgap] : 0

      columns = data[:columns]

      raise 'Missing value for grid columns' unless columns

      layout = GridLayout.new columns, hgap, vgap

      def layout.add_layout_extensions component

        return if component.respond_to?(:swiby_grid__actual_add)

        class << component
          alias :swiby_grid__actual_add :add
        end

        def component.add x
          jc = swiby_grid__actual_add x
          java_component.get_layout.addLayoutComponent x.java_component, "growx#{", span #{@pending_colspan}" if @pending_colspan}"
          @pending_colspan = nil
          jc
        end

        def component.column options
          @pending_colspan = options[:span]
        end

      end

      layout

    end

  end

  LayoutFactory.register_factory(GridFactory.new)

  module Builder

    def grid options = nil, &block

      options = {} unless options

      if options
        options[:layout] = :grid
      end

      panel(options, &block)
      
    end

  end

  class GridLayout

    include LayoutManager

    attr_accessor :hgap, :vgap

    def initialize(columns, hgap = 0, vgap = 0)

      @hgap = hgap
      @vgap = vgap

      wrap = ""
      col_constraint = "grow"

      case columns
      when String
        wrap = "wrap #{columns.count('[')},"
        col_constraint = "#{columns}"
      when Fixnum
        wrap = "wrap #{columns},"
      end
      
      @delegate_layout = MigLayout.new("#{wrap} gapx #{hgap}, gapy #{vgap}", "#{col_constraint}", "")

    end

    def addLayoutComponent(name, comp)
      @delegate_layout.addLayoutComponent(name, comp)
    end

    def removeLayoutComponent(comp)
      @delegate_layout.removeLayoutComponent(comp)
    end

    def preferredLayoutSize(parent)
      @delegate_layout.preferredLayoutSize(parent)
    end

    def minimumLayoutSize(parent)
      @delegate_layout.minimumLayoutSize(parent)
    end

    def maximumLayoutSize(parent)
      @delegate_layout.maximumLayoutSize(parent)
    end

    def layoutContainer(parent)
      @delegate_layout.layoutContainer(parent)
    end

  end

end
