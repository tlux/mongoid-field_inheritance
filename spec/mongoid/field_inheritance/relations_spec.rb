require 'spec_helper'

describe Mongoid::FieldInheritance::Relations do
  context '.belongs_to' do
    let!(:model) { ModelFactory.create_model }

    context 'with inherit option' do
      context 'with inferred foreign key' do
        before :each do
          model.belongs_to :manufacturer, inherit: true
        end

        it 'adds the foreign key field to inheritable fields' do
          expect(model.inheritable_fields).to include 'manufacturer_id'
        end
      end

      context 'with specified foreign key' do
        before :each do
          model.belongs_to :manufacturer, inherit: true, foreign_key: :m_id
        end

        it 'adds the foreign key field to inheritable fields' do
          expect(model.inheritable_fields).to include 'm_id'
        end
      end
    end

    context 'without inherit option' do
      before :each do
        model.belongs_to :manufacturer
      end

      it 'does not add foreign key to inheritable fields' do
        expect(model.inheritable_fields).to_not include 'manufacturer_id'
      end
    end
  end
end
