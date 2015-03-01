require 'spec_helper'

describe Mongoid::FieldInheritance::Management do
  let! :model do
    ModelFactory.create_model do
      field :name, localize: true, inherit: true
      field :manufacturer, inherit: true
      field :sku
    end
  end

  describe '#mark_inherited' do
    context 'without parent' do
      subject { model.new }

      it 'raises when model has no parent' do
        expect { subject.mark_inherited }.to raise_error(
          Mongoid::FieldInheritance::UndefinedParentError, 'No parent defined'
        )
      end
    end

    context 'with parent' do
      let! :parent do
        model.create manufacturer: 'Apple', name: 'iPhone', sku: '12345'
      end

      subject { parent.children.new }

      context 'without fields given' do
        it 'marks all inheritable fields inherited' do
          expect { subject.mark_inherited }.to(
            change { subject.inherited_fields }
            .from([]).to(%w(name manufacturer))
          )
        end
      end

      context 'with fields given' do
        it 'marks the specified fields inherited' do
          expect { subject.mark_inherited(:name) }.to(
            change { subject.inherited_fields }
            .from([]).to(%w(name))
          )
        end

        it 'raises when a field does not exist' do
          expect { subject.mark_inherited(:test) }.to(
            raise_error Mongoid::FieldInheritance::UninheritableError,
                        'Field is not inheritable: test'
          )
        end

        it 'raises when a field is not inheritable' do
          expect { subject.mark_inherited(:sku, :test) }.to(
            raise_error Mongoid::FieldInheritance::UninheritableError,
                        'Fields are not inheritable: sku, test'
          )
        end
      end
    end
  end

  describe '#inherit' do
    context 'without parent' do
      subject { model.new }

      it 'raises when model has no parent' do
        expect { subject.inherit }.to raise_error(
          Mongoid::FieldInheritance::UndefinedParentError, 'No parent defined'
        )
      end
    end

    context 'with parent' do
      let! :parent do
        model.create manufacturer: 'Apple', name: 'iPhone', sku: '12345'
      end

      subject { parent.children.new }

      context 'without options' do
        it 'adds all inheritable fields to inherited fields' do
          expect { subject.inherit }.to(
            change { subject.inherited_fields }
            .from([]).to(model.inheritable_fields.keys)
          )
        end
      end

      context 'with :only option' do
        it 'adds the specified fields to inherited fields' do
          expect { subject.inherit only: :manufacturer }.to(
            change { subject.inherited_fields }
            .from([]).to(%w(manufacturer))
          )
        end
      end

      context 'with :except option' do
        it 'adds all inheritable except the specified fields to inherited ' \
           'fields' do
          expect { subject.inherit except: :manufacturer }.to(
            change { subject.inherited_fields }
            .from([]).to(%w(name))
          )
        end
      end

      context 'with :only and :except options' do
        it 'raises' do
          expect {
            subject.inherit(only: %w(manufacturer), except: %w(name))
          }.to raise_error(
            ArgumentError, ':only and :except cannot be specified at once'
          )
        end
      end
    end
  end

  describe '#inherit!' do
    context 'without parent' do
      subject { model.new }

      it 'raises when model has no parent' do
        expect { subject.inherit! }.to raise_error(
          Mongoid::FieldInheritance::UndefinedParentError, 'No parent defined'
        )
      end
    end

    context 'with parent' do
      let! :parent do
        model.create manufacturer: 'Apple', name: 'iPhone', sku: '12345'
      end

      subject { parent.children.new }

      it 'saves the document' do
        expect { subject.inherit! }.to(
          change { subject.persisted? }.from(false).to(true)
        )
      end

      context 'without options' do
        it 'adds all inheritable fields to inherited fields' do
          expect { subject.inherit! }.to(
            change { subject.inherited_fields }
            .from([]).to(model.inheritable_fields.keys)
          )
        end
      end

      context 'with :only option' do
        it 'adds the specified fields to inherited fields' do
          expect { subject.inherit! only: :manufacturer }.to(
            change { subject.inherited_fields }
            .from([]).to(%w(manufacturer))
          )
        end
      end

      context 'with :except option' do
        it 'adds all inheritable except the specified fields to inherited ' \
           'fields' do
          expect { subject.inherit! except: :manufacturer }.to(
            change { subject.inherited_fields }
            .from([]).to(%w(name))
          )
        end
      end

      context 'with :only and :except options' do
        it 'raises' do
          expect {
            subject.inherit!(only: %w(manufacturer), except: %w(name))
          }.to raise_error(
            ArgumentError, ':only and :except cannot be specified at once'
          )
        end
      end
    end
  end

  describe '#mark_overridden' do
    subject do
      model.create manufacturer: 'Apple', name: 'iPhone', sku: '12345',
                   inherited_fields: model.inheritable_fields.keys
    end

    context 'without fields given' do
      it 'removes all inherited fields' do
        expect { subject.mark_overridden }.to(
          change { subject.inherited_fields }
          .from(model.inheritable_fields.keys).to([])
        )
      end
    end

    context 'with fields given' do
      it 'removes the specified fields from inherited fields' do
        expect { subject.mark_overridden(:name) }.to(
          change { subject.inherited_fields }
          .from(model.inheritable_fields.keys).to(%w(manufacturer))
        )
      end

      it 'is not whiny when a field does not exist' do
        expect { subject.mark_overridden(:test) }.not_to raise_error
      end

      it 'is not whiny when a field is not inheritable' do
        expect { subject.mark_overridden(:sku, :test) }.not_to raise_error
      end
    end
  end

  describe '#override' do
    context 'without parent' do
      subject { model.new }

      it 'does not raise when model has no parent' do
        expect { subject.override }.not_to raise_error
      end
    end

    context 'with parent' do
      let! :parent do
        model.create manufacturer: 'Apple', name: 'iPhone', sku: '12345'
      end

      subject { parent.children.new(inherited_fields: %w(name manufacturer)) }

      context 'without options' do
        it 'removes all inherited fields' do
          expect { subject.override }.to(
            change { subject.inherited_fields }
            .from(%w(name manufacturer)).to([])
          )
        end
      end

      context 'with :only option' do
        it 'removes the specified fields from inherited fields' do
          expect { subject.override only: :manufacturer }.to(
            change { subject.inherited_fields }
            .from(%w(name manufacturer)).to(%w(name))
          )
        end
      end

      context 'with :except option' do
        it 'removes all fields except the specified fields from inherited ' \
           'fields' do
          expect { subject.override except: :manufacturer }.to(
            change { subject.inherited_fields }
            .from(%w(name manufacturer)).to(%w(manufacturer))
          )
        end
      end

      context 'with :only and :except options' do
        it 'raises' do
          expect {
            subject.override(only: %w(manufacturer), except: %w(name))
          }.to raise_error(
            ArgumentError, ':only and :except cannot be specified at once'
          )
        end
      end
    end
  end

  describe '#override!' do
    context 'without parent' do
      subject { model.new }

      it 'does not raise when model has no parent' do
        expect { subject.override }.not_to raise_error
      end
    end

    context 'with parent' do
      let! :parent do
        model.create manufacturer: 'Apple', name: 'iPhone', sku: '12345'
      end

      subject { parent.children.new(inherited_fields: %w(name manufacturer)) }

      it 'saves the document' do
        expect { subject.override! }.to(
          change { subject.persisted? }.from(false).to(true)
        )
      end

      context 'without options' do
        it 'removes all inherited fields' do
          expect { subject.override! }.to(
            change { subject.inherited_fields }
            .from(%w(name manufacturer)).to([])
          )
        end
      end

      context 'with :only option' do
        it 'removes the specified fields from inherited fields' do
          expect { subject.override! only: :manufacturer }.to(
            change { subject.inherited_fields }
            .from(%w(name manufacturer)).to(%w(name))
          )
        end
      end

      context 'with :except option' do
        it 'removes all fields except the specified fields from inherited ' \
           'fields' do
          expect { subject.override! except: :manufacturer }.to(
            change { subject.inherited_fields }
            .from(%w(name manufacturer)).to(%w(manufacturer))
          )
        end
      end

      context 'with :only and :except options' do
        it 'raises' do
          expect {
            subject.override!(only: %w(manufacturer), except: %w(name))
          }.to raise_error(
            ArgumentError, ':only and :except cannot be specified at once'
          )
        end
      end
    end
  end
end
