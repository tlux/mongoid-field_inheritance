require 'spec_helper'

describe Mongoid::FieldInheritance::Fields do
  let! :model do
    ModelFactory.create_model do
      field :name, localize: true, inherit: true
      field :manufacturer, inherit: true
      field :sku
    end
  end

  describe '#field_inherited?' do
    subject { model.new }

    before :each do
      allow(subject).to receive(:inherited_fields).and_return %w(name)
    end

    context 'when the attribute is inherited' do
      it 'returns true specifying the field name as Symbol' do
        expect(subject.field_inherited?(:name)).to be true
      end

      it 'returns true specifying the field name as String' do
        expect(subject.field_inherited?('name')).to be true
      end
    end

    context 'when the attribute is not inherited' do
      it 'returns false specifying the field name as Symbol' do
        expect(subject.field_inherited?(:manufacturer)).to be false
      end

      it 'returns false specifying the field name as String' do
        expect(subject.field_inherited?('manufacturer')).to be false
      end
    end

    describe 'dynamic inquiry method' do
      it 'responds for inherited field' do
        expect(subject).to respond_to(:name_inherited?)
      end

      it 'does not respond for non-inherited field' do
        expect(subject).to_not respond_to(:sku_inherited?)
      end
    end
  end
end
