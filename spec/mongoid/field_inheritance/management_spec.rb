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
      # TODO
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
      # TODO
    end
  end

  describe '#mark_overridden' do
    # TODO
  end

  describe '#override' do
    # TODO
  end

  describe '#override!' do
    # TODO
  end
end
