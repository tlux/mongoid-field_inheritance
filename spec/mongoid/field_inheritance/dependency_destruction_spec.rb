require 'spec_helper'

describe Mongoid::FieldInheritance::DependencyDestruction do
  after :each do
    Product.reset_inheritance
    Product.destroy_inherited_via = :destroy
  end

  describe '#destroy' do
    subject { Product.create!(manufacturer: 'Samsung') }

    before :each do
      child = subject.children.create!
      child.children.create!
    end

    context 'when delete_descendants is false' do
      before :each do
        Product.destroy_inherited_via = :destroy
      end

      it 'destroys self and descendants' do
        expect { subject.destroy }.to change(Product, :count).by(-3)
      end
    end

    context 'when delete_descendants is true' do
      before :each do
        Product.destroy_inherited_via = :delete
      end

      it 'deletes self and descendants' do
        expect { subject.destroy }.to change(Product, :count).by(-3)
      end
    end
  end
end
