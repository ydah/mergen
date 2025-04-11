# frozen_string_literal: true

module Mergen
  class Parser
    def parse(content)
      res = []
      current_class = nil
      current_visibility = :public

      content.each_line do |line|
        line = line.strip
        if line =~ /^class\s+([A-Z][A-Za-z0-9_]*)\s*(<\s*([A-Z][A-Za-z0-9_:]*))?\s*$/
          class_name = ::Regexp.last_match(1)
          parent_class = ::Regexp.last_match(3)
          current_class = Diagram.new(class_name)
          current_class.set_parent_class(parent_class) if parent_class
          res << current_class
          current_visibility = :public
        elsif line =~ /^module\s+([A-Z][A-Za-z0-9_]*)\s*$/
          module_name = ::Regexp.last_match(1)
          current_class = Diagram.new(module_name, :module)
          res << current_class
          current_visibility = :public
        elsif current_class && line =~ /^\s*include\s+([A-Z][A-Za-z0-9_:]*)\s*$/
          current_class.add_included_module(::Regexp.last_match(1))
        elsif current_class && line =~ /^\s*def\s+([a-z_][a-zA-Z0-9_]*[?!=]?)/
          current_class.add_method(::Regexp.last_match(1), current_visibility)
        elsif current_class && line =~ /^\s*(attr_accessor|attr_reader|attr_writer)\s+(:[a-z_][a-zA-Z0-9_]*(?:\s*,\s*:[a-z_][a-zA-Z0-9_]*)*)/
          attr_type = ::Regexp.last_match(1).to_sym
          attr_list = ::Regexp.last_match(2)
          attr_list.scan(/:[a-z_][a-zA-Z0-9_]*/).each do |attr|
            attr_name = attr.sub(/^:/, '')
            current_class.add_attribute(attr_name, current_visibility, attr_type)
          end
        elsif current_class && line =~ /^\s*(private|protected|public)\s*$/
          current_visibility = ::Regexp.last_match(1).to_sym
        end
      end
      res
    end
  end
end
