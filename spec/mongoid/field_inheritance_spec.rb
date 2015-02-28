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
