require 'spec_helper'

describe Mongoid::FieldInheritance::Macro do
  after :each do
    Product.reset_inheritance
  end

  describe '.inherits' do
    it 'raises when no fields have been specified' do
      expect { Product.inherits }.to raise_error(
        ArgumentError, 'No inheritable fields defined'
      )
    end

    it 'raises when an invalid field has been specified' do
      expect { Product.inherits :manufacturer, :_id }.to raise_error(
        ArgumentError, 'Field may not be inherited: _id'
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

    it 'does not remove dynamic methods from parent' do
      expect { Cellphone.reset_inheritance }.not_to(
        change { Product.instance_methods.include?(:name_inherited?) }
      )
    end
  end
end
