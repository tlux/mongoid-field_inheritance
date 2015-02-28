require 'spec_helper'

describe Mongoid::FieldInheritance do
  after :each do
    Product.reset_inheritance
  end

  context 'when included' do
    it 'has a parent association' do
      association_class = Product.reflect_on_association(:parent).class_name
      expect(association_class).to eq Product.name
    end

    it 'has a children association' do
      association_class = Product.reflect_on_association(:children).class_name
      expect(association_class).to eq Product.name
    end
  end

  describe '.inheritable_fields' do
    before :each do
      Product.inherits :name, :manufacturer
      Cellphone.inherits :sku
    end

    it 'copies inheritable fields to a subclass' do
      expect(Cellphone.inheritable_fields).to include 'name'
    end

    it 'may add more inheritable fields to a subclass' do
      expect(Cellphone.inheritable_fields).to include 'sku'
    end

    it 'does not add additional inheritable fields affect the parent model' do
      expect(Product.inheritable_fields).to_not include 'sku'
    end
  end

  describe '#valid?' do
    before :each do
      Product.inherits :name, :manufacturer
    end

    subject { Product.new }

    before :each do
      allow(subject).to receive(:root?).and_return false
      subject.inherited_fields = %w(manufacturer)
    end

    it 'adds an error when inherited fields are set to a ' \
       'non-inheritable field' do
      subject.inherited_fields << 'sku'
      expect(subject.valid?).to be false
      expect(subject.errors[:inherited_fields].count).to eq 1
    end

    it 'adds no error when inherited fields are set to an inheritable field' do
      expect(subject.valid?).to be true
      expect(subject.errors[:inherited_fields].count).to eq 0
    end

    it 'adds an error when inherited fields are present on a root record' do
      allow(subject).to receive(:root?).and_return true
      expect(subject.valid?).to be false
      expect(subject.errors[:inherited_fields].count).to eq 1
    end

    it 'adds no error when inherited fields are present on a nested record' do
      expect(subject.valid?).to be true
      expect(subject.errors[:inherited_fields].count).to eq 0
    end
  end
end
