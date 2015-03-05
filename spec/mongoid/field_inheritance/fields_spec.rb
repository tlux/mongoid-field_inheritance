require 'spec_helper'

describe Mongoid::FieldInheritance::Fields do
  let! :model do
    ModelFactory.create_model do
      field :name, localize: true, inherit: true
      field :manufacturer, inherit: true
      field :sku
    end
  end

  describe '#field_inherited?', '#field_inherited' do
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

    describe 'dynamically generated methods' do
      it 'responds to reader' do
        expect(subject).to respond_to(:name_inherited)
      end

      it 'responds to inquiry method' do
        expect(subject).to respond_to(:name_inherited?)
      end

      it 'does not respond for non-inherited field' do
        expect(subject).to_not respond_to(:sku_inherited?)
      end
    end
  end

  describe '#mark_field_inherited' do
    subject { model.new }

    before :each do
      allow(subject).to receive(:root?).and_return false
    end

    it 'adds a field to inherited fields when true' do
      expect { subject.mark_field_inherited(:name, true) }.to(
        change { subject.inherited_fields }.from([]).to(%w(name))
      )
    end

    it 'removes a field from inherited fields when false' do
      subject.inherited_fields = %w(name manufacturer)

      expect { subject.mark_field_inherited(:name, false) }.to(
        change { subject.inherited_fields }
        .from(%w(name manufacturer)).to(%w(manufacturer))
      )
    end

    describe 'dynamically generated method' do
      it 'responds to writer' do
        expect(subject).to respond_to(:name_inherited=)
      end

      context 'setting field inherited' do
        it 'adds the field to inherited fields when true' do
          expect { subject.name_inherited = true }.to(
            change { subject.name_inherited? }.from(false).to(true)
          )
        end

        it 'adds the field to inherited fields when 1' do
          expect { subject.name_inherited = 1 }.to(
            change { subject.name_inherited? }.from(false).to(true)
          )
        end

        it 'adds the field to inherited fields when "1"' do
          expect { subject.name_inherited = '1' }.to(
            change { subject.name_inherited? }.from(false).to(true)
          )
        end

        it 'adds the field to inherited fields when "t"' do
          expect { subject.name_inherited = 't' }.to(
            change { subject.name_inherited? }.from(false).to(true)
          )
        end

        it 'adds the field to inherited fields when "true"' do
          expect { subject.name_inherited = 'true' }.to(
            change { subject.name_inherited? }.from(false).to(true)
          )
        end
      end

      context 'setting field overridden' do
        before :each do
          subject.inherited_fields = %w(name)
        end

        it 'removes the field from inherited fields when nil' do
          expect { subject.name_inherited = nil }.to(
            change { subject.name_inherited? }.from(true).to(false)
          )
        end

        it 'removes the field from inherited fields when false' do
          expect { subject.name_inherited = false }.to(
            change { subject.name_inherited? }.from(true).to(false)
          )
        end

        it 'removes the field from inherited fields when 0' do
          expect { subject.name_inherited = 0 }.to(
            change { subject.name_inherited? }.from(true).to(false)
          )
        end

        it 'removes the field from inherited fields when "0"' do
          expect { subject.name_inherited = '0' }.to(
            change { subject.name_inherited? }.from(true).to(false)
          )
        end

        it 'removes the field from inherited fields when "f"' do
          expect { subject.name_inherited = 'f' }.to(
            change { subject.name_inherited? }.from(true).to(false)
          )
        end

        it 'removes the field from inherited fields when "false"' do
          expect { subject.name_inherited = 'false' }.to(
            change { subject.name_inherited? }.from(true).to(false)
          )
        end
      end
    end
  end
end
