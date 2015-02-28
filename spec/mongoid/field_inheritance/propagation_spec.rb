require 'spec_helper'

describe Mongoid::FieldInheritance::Propagation do
  describe '#save' do
    before :each do
      Product.inherits :manufacturer, :name
    end

    context 'with parent' do
      let! :parent do
        Product.create! manufacturer: 'Apple', name: 'iPhone', sku: '12345'
      end

      subject do
        child = parent.children.new
        child.inherit_all
        child.name = 'iPod'
        child.tap(&:save!)
      end

      it 'copies the inheritable fields from parent' do
        expect(subject.manufacturer).to eq 'Apple'
      end

      it 'overwrites child-defined value if field is among inherited fields' do
        expect(subject.name).to eq 'iPhone'
      end

      it 'does not copy the uninheritable fields from parent' do
        expect(subject.sku).to be nil
      end
    end

    context 'with children' do
      subject { Product.create! manufacturer: 'Apple', name: 'iPhone' }

      let! :child do
        subject.children.create! do |child|
          child.inherit :manufacturer
        end
      end

      let! :grandchild do
        child.children.create! do |grandchild|
          grandchild.inherit :manufacturer
        end
      end

      it 'propagates to inherited attribute in child' do
        expect { subject.update(manufacturer: 'Samsung') }.to change {
          child.reload.manufacturer
        }.from('Apple').to('Samsung')
      end

      it 'propagates to inherited attribute in grandchild' do
        expect { subject.update(manufacturer: 'HTC') }.to change {
          grandchild.reload.manufacturer
        }.from('Apple').to('HTC')
      end

      it 'does not update inheriting child if nothing has changed' do
        expect { subject.update(name: 'iPhone') }.not_to change {
          child.reload.updated_at
        }
      end

      it 'does not propagate to non-inherited attributes of children' do
        expect { subject.update(name: 'One') }.not_to change {
          child.reload.name
        }
      end
    end
  end
end
