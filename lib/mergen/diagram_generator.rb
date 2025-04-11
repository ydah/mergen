# frozen_string_literal: true

module Mergen
  class DiagramGenerator
    def initialize(diagrams)
      @diagrams = diagrams
    end

    def generate
      lines = ['classDiagram']

      @diagrams.each do |info|
        if info.type == :module
          lines << "  class #{info.name} {\n    <<module>>\n  }"
        else
          lines << "  class #{info.name} {"

          info.attributes.each do |attr|
            visibility = case attr[:visibility]
                         when :private then '-'
                         when :protected then '#'
                         else '+'
                         end

            attr_type = case attr[:type]
                        when :attr_reader then 'getter'
                        when :attr_writer then 'setter'
                        else 'property'
                        end

            lines << "    #{visibility} #{attr[:name]} : #{attr_type}"
          end

          info.methods.each do |method|
            visibility = case method[:visibility]
                         when :private then '-'
                         when :protected then '#'
                         else '+'
                         end

            lines << "    #{visibility} #{method[:name]}()"
          end

          lines << '  }'
        end

        lines << "  #{info.parent_class} <|-- #{info.name}" if info.parent_class

        info.included_modules.each do |mod|
          lines << "  #{mod} <|.. #{info.name} : includes"
        end
      end

      lines.join("\n")
    end
  end
end
