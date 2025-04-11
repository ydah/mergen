# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mergen::DiagramGenerator do
  let(:class_infos) { [] }
  let(:generator) { described_class.new(class_infos) }

  describe '#generate' do
    context 'with an empty class list' do
      it 'generates a basic diagram structure' do
        diagram = generator.generate
        expect(diagram).to include('classDiagram')
      end
    end

    context 'with a single class' do
      before do
        class_info = Mergen::Diagram.new('Person')
        class_info.add_attribute('name')
        class_info.add_attribute('age')
        class_info.add_method('initialize')
        class_info.add_method('greet')

        class_infos << class_info
      end

      it 'generates a diagram with the class' do
        diagram = generator.generate

        expect(diagram).to include('class Person {')
        expect(diagram).to include('+ name : property')
        expect(diagram).to include('+ age : property')
        expect(diagram).to include('+ initialize()')
        expect(diagram).to include('+ greet()')
      end
    end

    context 'with inheritance relationship' do
      before do
        parent = Mergen::Diagram.new('Animal')
        parent.add_method('speak')

        child = Mergen::Diagram.new('Dog')
        child.set_parent_class('Animal')
        child.add_method('bark')

        class_infos << parent
        class_infos << child
      end

      it 'generates a diagram with inheritance relationship' do
        diagram = generator.generate

        expect(diagram).to include('class Animal {')
        expect(diagram).to include('class Dog {')
        expect(diagram).to include('Animal <|-- Dog')
      end
    end

    context 'with modules and includes' do
      before do
        module_info = Mergen::Diagram.new('Loggable', :module)
        module_info.add_method('log')

        class_info = Mergen::Diagram.new('Service')
        class_info.add_included_module('Loggable')
        class_info.add_method('perform')

        class_infos << module_info
        class_infos << class_info
      end

      it 'generates a diagram with module and include relationship' do
        diagram = generator.generate

        expect(diagram).to include('class Loggable {')
        expect(diagram).to include('<<module>>')
        expect(diagram).to include('class Service {')
        expect(diagram).to include('Loggable <|.. Service : includes')
      end
    end
  end
end
