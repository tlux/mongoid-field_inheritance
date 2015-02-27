require 'spec_helper'

describe Mongoid::FieldInheritance do
  context 'when included' do
    subject { Product }

    it 'has a parent association' do
      association_class = subject.reflect_on_association(:parent).class_name
      expect(association_class).to eq subject.name
    end

    it 'has a children association' do
      association_class = subject.reflect_on_association(:children).class_name
      expect(association_class).to eq subject.name
    end
  end
end
