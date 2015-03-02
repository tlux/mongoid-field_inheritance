require 'spec_helper'

describe Mongoid::FieldInheritance::Dependent do
  let! :model do
    ModelFactory.create_model do
      field :manufacturer, inherit: true
    end
  end

  it 'has :destroy dependency strategy by default' do
    expect(model.inheritance_options[:dependent]).to eq :destroy
  end

  describe '#destroy' do
    subject { model.create!(manufacturer: 'Samsung') }

    before :each do
      child = subject.children.create!
      child.children.create!
    end

    context 'with destroy strategy' do
      before :each do
        model.inheritable dependent: :destroy
      end

      it 'destroys self and descendants' do
        expect { subject.destroy }.to change(model, :count).by(-3)
      end
    end

    context 'with destroy_all strategy' do
      before :each do
        model.inheritable dependent: :destroy_all
      end

      it 'destroys self and descendants' do
        expect { subject.destroy }.to change(model, :count).by(-3)
      end
    end

    context 'with delete strategy' do
      before :each do
        model.inheritable dependent: :delete
      end

      it 'deletes self and descendants' do
        expect { subject.destroy }.to change(model, :count).by(-3)
      end
    end

    context 'with delete_all strategy' do
      before :each do
        model.inheritable dependent: :delete_all
      end

      it 'deletes self and descendants' do
        expect { subject.destroy }.to change(model, :count).by(-3)
      end
    end
  end
end
