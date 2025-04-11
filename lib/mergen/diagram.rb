# frozen_string_literal: true

module Mergen
  class Diagram
    attr_reader :name, :type, :parent_class, :included_modules, :methods, :attributes

    def initialize(name, type = :class)
      @name = name
      @type = type
      @parent_class = nil
      @included_modules = []
      @methods = []
      @attributes = []
    end

    def set_parent_class(parent_class)
      @parent_class = parent_class
    end

    def add_included_module(module_name)
      @included_modules << module_name
    end

    def add_method(method_name, visibility = :public)
      @methods << { name: method_name, visibility: visibility }
    end

    def add_attribute(attr_name, visibility = :public, type = :attr_accessor)
      @attributes << { name: attr_name, visibility: visibility, type: type }
    end
  end
end
