# frozen_string_literal: true

require 'mergen/version'
require 'mergen/parser'
require 'mergen/diagram'
require 'mergen/diagram_generator'

module Mergen
  class Generator
    def initialize(path)
      @path = path
      @parser = Parser.new
    end

    def generate
      diagrams = []
      targets(@path).each do |file|
        file_content = File.read(file)
        diagrams.concat(@parser.parse(file_content))
      end

      DiagramGenerator.new(diagrams).generate
    end

    private

    def targets(path)
      if File.directory?(path)
        Dir.glob(File.join(path, '**', '*.rb'))
      elsif File.file?(path) && path.end_with?('.rb')
        [path]
      else
        []
      end
    end
  end
end
