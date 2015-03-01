require 'spec_helper'

describe Mongoid::FieldInheritance::Management do
  let! :model do
    ModelFactory.create_model do
      field :name, localize: true, inherit: true
      field :manufacturer, inherit: true
      field :sku
    end
  end

  subject { model.new }

  describe '#mark_inherited' do
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

  describe '#inherit' do
  end

  describe '#inherit!' do
  end

  describe '#mark_overridden' do
  end

  describe '#override' do
  end

  describe '#override!' do
  end
end
