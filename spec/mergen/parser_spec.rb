# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mergen::Parser do
  let(:parser) { described_class.new }

  describe '#parse' do
    context 'with a simple class' do
      let(:code) do
        <<~RUBY
          class Person
            attr_accessor :name, :age
          #{'  '}
            def initialize(name, age)
              @name = name
              @age = age
            end
          #{'  '}
            def greet
              "Hello, my name is \#{@name}!"
            end
          #{'  '}
            private
          #{'  '}
            def private_method
              "This is private"
            end
          end
        RUBY
      end

      it 'correctly parses class information' do
        parsed = parser.parse(code)

        expect(parsed.size).to eq(1)
        expect(parsed.first.name).to eq('Person')
        expect(parsed.first.type).to eq(:class)
        expect(parsed.first.parent_class).to be_nil
        expect(parsed.first.included_modules).to be_empty
      end

      it 'extracts methods with correct visibility' do
        parsed = parser.parse(code)
        methods = parsed.first.methods

        expect(methods.size).to eq(3)

        initialize_method = methods.find { |m| m[:name] == 'initialize' }
        expect(initialize_method).not_to be_nil
        expect(initialize_method[:visibility]).to eq(:public)

        greet_method = methods.find { |m| m[:name] == 'greet' }
        expect(greet_method).not_to be_nil
        expect(greet_method[:visibility]).to eq(:public)

        private_method = methods.find { |m| m[:name] == 'private_method' }
        expect(private_method).not_to be_nil
        expect(private_method[:visibility]).to eq(:private)
      end

      it 'extracts attributes' do
        parsed = parser.parse(code)
        attributes = parsed.first.attributes

        expect(attributes.size).to eq(2)

        name_attr = attributes.find { |a| a[:name] == 'name' }
        expect(name_attr).not_to be_nil
        expect(name_attr[:visibility]).to eq(:public)
        expect(name_attr[:type]).to eq(:attr_accessor)

        age_attr = attributes.find { |a| a[:name] == 'age' }
        expect(age_attr).not_to be_nil
        expect(age_attr[:visibility]).to eq(:public)
        expect(age_attr[:type]).to eq(:attr_accessor)
      end
    end

    context 'with inheritance' do
      let(:code) do
        <<~RUBY
          class Animal
            attr_reader :species
          #{'  '}
            def speak
              "Some sound"
            end
          end

          class Dog < Animal
            def speak
              "Woof!"
            end
          end
        RUBY
      end

      it 'correctly identifies parent-child relationships' do
        parsed = parser.parse(code)

        expect(parsed.size).to eq(2)

        animal_class = parsed.find { |c| c.name == 'Animal' }
        expect(animal_class).not_to be_nil
        expect(animal_class.parent_class).to be_nil

        dog_class = parsed.find { |c| c.name == 'Dog' }
        expect(dog_class).not_to be_nil
        expect(dog_class.parent_class).to eq('Animal')
      end
    end

    context 'with modules and includes' do
      let(:code) do
        <<~RUBY
          module Loggable
            def log(message)
              puts "[LOG] \#{message}"
            end
          end

          class Service
            include Loggable
          #{'  '}
            def perform
              log("Service performed")
            end
          end
        RUBY
      end

      it 'correctly identifies modules and includes' do
        parsed = parser.parse(code)

        expect(parsed.size).to eq(2)

        module_info = parsed.find { |c| c.name == 'Loggable' }
        expect(module_info).not_to be_nil
        expect(module_info.type).to eq(:module)

        class_info = parsed.find { |c| c.name == 'Service' }
        expect(class_info).not_to be_nil
        expect(class_info.type).to eq(:class)
        expect(class_info.included_modules).to include('Loggable')
      end
    end
  end
end
