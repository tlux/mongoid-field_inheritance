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

  describe '.inherits' do
    it 'raises when no fields have been specified' do
      expect { Product.inherits }.to raise_error(
        ArgumentError, 'No inheritable fields defined'
      )
    end

    it 'raises when an invalid field has been specified' do
      expect { Product.inherits :manufacturer, :_id }.to raise_error(
        ArgumentError, 'Cannot inherit fields: ' +
                       Mongoid::FieldInheritance::INVALID_FIELDS.join(', ')
      )
    end

    it 'allows defining inheritable fields as arguments' do
      Product.inherits :manufacturer, :name
      expect(Product.inheritable_fields).to match_array %w(manufacturer name)
    end

    it 'allows defining inheritable fields as Array' do
      Product.inherits [:manufacturer, :name]
      expect(Product.inheritable_fields).to match_array %w(manufacturer name)
    end
  end

  describe '.reset_inheritance' do
    before :each do
      Product.inherits :name, :manufacturer
    end

    it 'removes all inheritable fields' do
      expect { Product.reset_inheritance }.to(
        change { Product.inheritable_fields }.from(%w(name manufacturer)).to([])
      )
    end

    it 'removes all dynamic methods' do
      expect { Product.reset_inheritance }.to(
        change { Product.instance_methods.include?(:name_inherited?) }
        .from(true).to(false)
      )
    end
  end
end
