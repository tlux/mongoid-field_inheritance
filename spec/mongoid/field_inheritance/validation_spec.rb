require 'spec_helper'

describe Mongoid::FieldInheritance::Validation do
  let! :model do
    ModelFactory.create_model do
      field :name, localize: true, inherit: true
      field :manufacturer, inherit: true
      field :sku
    end
  end

  subject { model.new }

  describe '#valid?' do
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
end
