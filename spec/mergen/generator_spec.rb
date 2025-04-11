# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mergen::Generator do
  let(:test_files_dir) { File.join(File.dirname(__FILE__), '..', 'fixtures') }
  let(:generator) { described_class.new(test_files_dir) }

  describe '#generate', :integration do
    before do
      FileUtils.mkdir_p(test_files_dir)

      File.write(File.join(test_files_dir, 'person.rb'), <<~RUBY
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
        end
      RUBY
      )

      File.write(File.join(test_files_dir, 'employee.rb'), <<~RUBY
        class Employee < Person
          attr_accessor :department
        #{'  '}
          def initialize(name, age, department)
            super(name, age)
            @department = department
          end
        #{'  '}
          def work
            "Working in \#{@department}..."
          end
        end
      RUBY
      )
    end

    after do
      FileUtils.rm_rf(test_files_dir)
    end

    it 'generates a diagram from Ruby files' do
      diagram = generator.generate

      expect(diagram).to include('classDiagram')
      expect(diagram).to include('class Person {')
      expect(diagram).to include('class Employee {')
      expect(diagram).to include('Person <|-- Employee')
    end
  end

  describe '#targets' do
    before do
      allow(File).to receive(:directory?).and_return(true)
      allow(Dir).to receive(:glob).and_return(['file1.rb', 'file2.rb'])
    end

    it 'collects Ruby files from a directory' do
      files = generator.send(:targets, test_files_dir)
      expect(files).to eq(['file1.rb', 'file2.rb'])
    end
  end
end
