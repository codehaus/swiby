#--
# Copyright (C) Swiby Committers. All rights reserved.
# 
# The software in this package is published under the terms of the BSD
# style license a copy of which has been included with this distribution in
# the LICENSE.txt file.
#
#++

require 'swiby/mvc/button'

import javax.swing.JFileChooser
import javax.swing.filechooser.FileFilter

module Swiby

  class ExtensionFilter < FileFilter

    def initialize descritpion, *extensions
      
      super()
      
      @descritpion, @extensions = descritpion, extensions
      
    end
    
    def accept file
      
      return true if file.directory?
      
      @extensions.each do |extension|
        return true if file.name =~ /\.#{extension}$/
      end
      
      false
      
    end
    
    def getDescription
      @descritpion
    end
    
  end

  class FileFilterBuilder
    
    attr_reader :filters
    
    def initialize
      @filters = []
    end
    
    def add description, *extensions
      @filters << ExtensionFilter.new(description, *extensions)
    end
    
  end
  
  module Builder
  
    def open_file text, image = nil, options = nil, &file_filter_definition
      create_open_save_file(:showOpenDialog, text, image, options, &file_filter_definition)
    end

    def save_file text, image = nil, options = nil, &file_filter_definition
      create_open_save_file(:showSaveDialog, text, image, options, &file_filter_definition)
    end
    
    def create_open_save_file method, text, image = nil, options = nil, &file_filter_definition
      
      but = button_factory(text, image, options, nil) do |opt|
        DialogButton.new(opt)
      end
      
      if file_filter_definition
        
        filter_builder = FileFilterBuilder.new
      
        file_filter_definition.call filter_builder 
      
        file_filters = filter_builder.filters
        
      else
        file_filters = []
      end
      
      but.action do
        
        fc = JFileChooser.new
        
        if file_filters.length > 0
          
          fc.setAcceptAllFileFilterUsed false
          
          file_filters.each do |file_filter|
            fc.addChoosableFileFilter file_filter
          end
        
        end
        
        result = fc.send(method, but.java_component.root_pane)
    
        but.file_selected fc.selected_file.absolute_path if result == JFileChooser::APPROVE_OPTION
        
      end
      
      but
      
    end
  
  end

  class DialogButton < Button
    
    class FileDialogRegistrar < ButtonRegistrar
      
      def create_listener
        self
      end
        
      def add_listener listener
        @wrapper.add_file_selection_listener self
      end
      
      def file_selected a_file
        @controller.send @action_method, a_file
        @master.refresh
      end
      
    end
  
    def add_file_selection_listener listener
      @file_selection_listeners = [] unless @file_selection_listeners
      @file_selection_listeners << listener
    end
    
    def file_selected a_file
      
      @file_selection_listeners.each do |listener|
        listener.file_selected a_file
      end
      
    end
    
    def create_registrar wrapper, master, controller, id, method_naming_provider
      FileDialogRegistrar.new(wrapper, master, controller, id, method_naming_provider)
    end
    
  end
  
end  