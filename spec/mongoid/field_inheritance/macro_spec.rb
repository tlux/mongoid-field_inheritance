require 'spec_helper'

describe Mongoid::FieldInheritance::Macro do
  subject :model do
    ModelFactory.create_model
  end

  describe '.field' do
    context 'when :inherit is false or undefined' do
      it 'does not add field to inheritable_fields' do
        expect { model.field :manufacturer }.to_not(
          change { model.inheritable_fields }
        )
      end

      it 'does not add an attribute_inherited? inquiry method to the model' do
        expect { model.field :manufacturer }.to_not(
          change { model.instance_methods.include?(:manufacturer_inherited?) }
        )
      end

      it 'succeeds when the field name is invalid for inheritance' do
        expect { model.field :updated_at }.not_to raise_error
      end
    end

    context 'when :inherit is true' do
      it 'adds field to inheritable_fields' do
        expect { model.field :manufacturer, inherit: true }.to(
          change { model.inheritable_fields.include?('manufacturer') }
          .from(false).to(true)
        )
      end

      it 'adds an field_inherited? inquiry method to the model' do
        expect { model.field :manufacturer, inherit: true }.to(
          change { model.instance_methods.include?(:manufacturer_inherited?) }
          .from(false).to(true)
        )
      end

      %w(_id _type created_at updated_at c_at u_at).each do |field|
        it "raises when the field name is #{field}" do
          expect { model.field :updated_at, inherit: true }.to(
            raise_error ArgumentError, 'Field cannot be inherited: updated_at'
          )
        end
      end
    end
  end

  describe '.inheritable' do
    it 'can set :dependent option' do
      expect { model.inheritable dependent: :delete_all }.to(
        change { model.inheritance_options[:dependent] }
        .from(:destroy).to(:delete_all)
      )
    end

    it 'raises when setting an unknown option' do
      expect { model.inheritable test: true }.to raise_error(
        ArgumentError, 'Unknown key: :test. Valid keys are: :dependent'
      )
    end
  end
end
