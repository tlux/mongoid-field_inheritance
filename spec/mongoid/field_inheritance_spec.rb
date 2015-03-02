require 'spec_helper'

describe Mongoid::FieldInheritance do
  let! :model do
    ModelFactory.create_model do
      field :name, localize: true, inherit: true
      field :manufacturer, inherit: true
      field :sku
    end
  end

  context 'when included' do
    it 'has a parent association' do
      association_class = model.reflect_on_association(:parent).class_name
      expect(association_class).to eq model.name
    end

    it 'has a children association' do
      association_class = model.reflect_on_association(:children).class_name
      expect(association_class).to eq model.name
    end
  end

  describe '.inheritable_fields' do
    let! :inherited_model do
      Class.new(model) do
        field :weight, inherit: true
      end
    end

    it 'copies inheritable fields to a subclass' do
      expect(inherited_model.inheritable_fields).to include 'name'
    end

    it 'may add more inheritable fields to a subclass' do
      expect(inherited_model.inheritable_fields).to include 'weight'
    end

    it 'does not add additional inheritable fields affect the parent model' do
      expect(model.inheritable_fields).to_not include 'weight'
    end
  end

  describe '#inherited_fields', '#inherited_fields=' do
    subject { model.new }

    it 'rejects nils' do
      subject.inherited_fields = [nil, 'name']
      subject.valid?
      expect(subject.inherited_fields).to eq %w(name)
    end

    it 'rejects blank Strings' do
      subject.inherited_fields = ['', 'name']
      subject.valid?
      expect(subject.inherited_fields).to eq %w(name)
    end
  end
end
