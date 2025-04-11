# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mergen::Diagram do
  let(:class_info) { described_class.new('TestClass') }

  describe '#initialize' do
    it 'creates a class info object with the given name' do
      expect(class_info.name).to eq('TestClass')
      expect(class_info.type).to eq(:class)
      expect(class_info.parent_class).to be_nil
      expect(class_info.included_modules).to be_empty
      expect(class_info.methods).to be_empty
      expect(class_info.attributes).to be_empty
    end

    it 'accepts a type parameter' do
      module_info = described_class.new('TestModule', :module)
      expect(module_info.type).to eq(:module)
    end
  end

  describe '#set_parent_class' do
    it 'sets the parent class' do
      class_info.set_parent_class('ParentClass')
      expect(class_info.parent_class).to eq('ParentClass')
    end
  end

  describe '#add_included_module' do
    it 'adds a module to the included modules list' do
      class_info.add_included_module('Comparable')
      expect(class_info.included_modules).to include('Comparable')
    end
  end

  describe '#add_method' do
    it 'adds a method with the specified visibility' do
      class_info.add_method('public_method')
      class_info.add_method('private_method', :private)

      methods = class_info.methods
      expect(methods.size).to eq(2)

      public_method = methods.find { |m| m[:name] == 'public_method' }
      expect(public_method[:visibility]).to eq(:public)

      private_method = methods.find { |m| m[:name] == 'private_method' }
      expect(private_method[:visibility]).to eq(:private)
    end
  end

  describe '#add_attribute' do
    it 'adds an attribute with the specified visibility and type' do
      class_info.add_attribute('name')
      class_info.add_attribute('age', :public, :attr_reader)
      class_info.add_attribute('address', :private, :attr_writer)

      attributes = class_info.attributes
      expect(attributes.size).to eq(3)

      name_attr = attributes.find { |a| a[:name] == 'name' }
      expect(name_attr[:visibility]).to eq(:public)
      expect(name_attr[:type]).to eq(:attr_accessor)

      age_attr = attributes.find { |a| a[:name] == 'age' }
      expect(age_attr[:visibility]).to eq(:public)
      expect(age_attr[:type]).to eq(:attr_reader)

      address_attr = attributes.find { |a| a[:name] == 'address' }
      expect(address_attr[:visibility]).to eq(:private)
      expect(address_attr[:type]).to eq(:attr_writer)
    end
  end
end
