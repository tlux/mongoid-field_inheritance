require 'spec_helper'

describe Mongoid::FieldInheritance::Macros do
  let! :model do
    ModelFactory.create_model
  end

  describe '.acts_as_inheritable' do
    it 'can set :dependent option' do
      expect { model.acts_as_inheritable dependent: :delete_all }.to(
        change { model.inheritance_options[:dependent] }
        .from(:destroy).to(:delete_all)
      )
    end

    it 'raises when setting an unknown option' do
      expect { model.acts_as_inheritable test: true }.to raise_error(
        ArgumentError, 'Unknown key: :test. Valid keys are: :dependent'
      )
    end
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
          expect { model.field field.to_sym, inherit: true }.to(
            raise_error Mongoid::FieldInheritance::UninheritableError,
                        "Field is not inheritable: #{field}"
          )
        end
      end
    end

    context 'when :inherit is a Symbol' do
      before :each do
        model.class_eval do
          field :manufacturer, inherit: :inherit_customized

          def inherit_customized(field, from)
            self[field] = "#{from[field]} TEST"
          end
        end
      end

      let!(:parent) { model.new(manufacturer: 'Apple') }
      subject { parent.children.new }

      it 'sets destination value by the inheritor-defined rule' do
        expect { subject.inherit }.to(
          change { subject.manufacturer }.from(nil).to('Apple TEST')
        )
      end
    end

    context 'when :inherit is a callable' do
      context 'when using self and 2 args' do
        before :each do
          model.field :manufacturer, inherit: ->(name, from) {
            self[name] = "TEST #{from[name]}"
          }
        end

        let!(:parent) { model.new(manufacturer: 'Apple') }
        subject { parent.children.new }

        it 'sets destination value by the inheritor-defined rule' do
          expect { subject.inherit }.to(
            change { subject.manufacturer }.from(nil).to('TEST Apple')
          )
        end
      end

      context 'with 3 args' do
        before :each do
          model.field :manufacturer, inherit: ->(name, src, dst) {
            dst[name] = "TEST #{src[name]}"
          }
        end

        let!(:parent) { model.new(manufacturer: 'Apple') }
        subject { parent.children.new }

        it 'sets destination value by the inheritor-defined rule' do
          expect { subject.inherit }.to(
            change { subject.manufacturer }.from(nil).to('TEST Apple')
          )
        end
      end
    end
  end

  describe '.inherit' do
    before :each do
      model.field :manufacturer
    end

    context 'no :with option or block defined' do
      before :each do
        model.class_eval do
          attr_accessor :color
        end
      end

      it 'raises when no fields have been specified' do
        expect { model.inherit }.to(
          raise_error ArgumentError, 'No field defined'
        )
      end

      it 'uses the default inheritance rule when defined field is a field' do
        model.inherit :manufacturer

        expect(model.inheritable_fields['manufacturer']).to(
          eq Mongoid::FieldInheritance::Inheritor
        )
      end

      it 'raises when defined field is an accessor' do
        expect { model.inherit :color }.to(
          raise_error ArgumentError, 'No inheritance rule defined'
        )
      end
    end

    context 'when :with is a Symbol' do
      before :each do
        model.class_eval do
          inherit :manufacturer, with: :inherit_customized

          def inherit_customized(field, from)
            self[field] = "#{from[field]} TEST"
          end
        end
      end

      let!(:parent) { model.new(manufacturer: 'Apple') }
      subject { parent.children.new }

      it 'sets destination value by the inheritor-defined rule' do
        expect { subject.inherit }.to(
          change { subject.manufacturer }.from(nil).to('Apple TEST')
        )
      end
    end

    context 'when :with is a callable' do
      context 'when using self and 2 args' do
        before :each do
          model.inherit :manufacturer, with: ->(name, from) {
            self[name] = "TEST #{from[name]}"
          }
        end

        let!(:parent) { model.new(manufacturer: 'Apple') }
        subject { parent.children.new }

        it 'sets destination value by the inheritor-defined rule' do
          expect { subject.inherit }.to(
            change { subject.manufacturer }.from(nil).to('TEST Apple')
          )
        end
      end

      context 'with 3 args' do
        before :each do
          model.inherit :manufacturer, with: ->(name, src, dst) {
            dst[name] = "TEST #{src[name]}"
          }
        end

        let!(:parent) { model.new(manufacturer: 'Apple') }
        subject { parent.children.new }

        it 'sets destination value by the inheritor-defined rule' do
          expect { subject.inherit }.to(
            change { subject.manufacturer }.from(nil).to('TEST Apple')
          )
        end
      end
    end

    context 'when block is given' do
      context 'when using self and 2 args' do
        before :each do
          model.inherit :manufacturer do |name, from|
            self[name] = "TEST #{from[name]}"
          end
        end

        let!(:parent) { model.new(manufacturer: 'Apple') }
        subject { parent.children.new }

        it 'sets destination value by the inheritor-defined rule' do
          expect { subject.inherit }.to(
            change { subject.manufacturer }.from(nil).to('TEST Apple')
          )
        end
      end

      context 'with 3 args' do
        before :each do
          model.inherit :manufacturer do |name, src, dst|
            dst[name] = "TEST #{src[name]}"
          end
        end

        let!(:parent) { model.new(manufacturer: 'Apple') }
        subject { parent.children.new }

        it 'sets destination value by the inheritor-defined rule' do
          expect { subject.inherit }.to(
            change { subject.manufacturer }.from(nil).to('TEST Apple')
          )
        end
      end
    end
  end
end
