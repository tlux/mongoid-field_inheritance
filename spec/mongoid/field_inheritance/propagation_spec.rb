require 'spec_helper'

describe Mongoid::FieldInheritance::Propagation do
  describe '#save' do
    context 'with fields' do
      let! :model do
        ModelFactory.create_model do
          include Mongoid::Timestamps::Updated

          field :name, localize: true, inherit: true
          field :manufacturer, inherit: true
          field :sku
        end
      end

      context 'with parent' do
        let! :parent do
          model.create manufacturer: 'Apple', name: 'iPhone', sku: '12345'
        end

        subject do
          parent.children.new(inherited_fields: %w(name manufacturer))
        end

        it 'copies the inheritable fields from parent before validation' do
          expect { subject.valid? }.to(
            change { subject.manufacturer }.from(nil).to('Apple')
          )
        end

        it 'copies the inheritable fields from parent before save' do
          expect { subject.save }.to(
            change { subject.manufacturer }.from(nil).to('Apple')
          )
        end

        it 'overwrites child-defined value if field is among inherited ' \
           'fields' do
          subject.manufacturer = 'Samsung'
          expect { subject.save }.to(
            change { subject.manufacturer }.from('Samsung').to('Apple')
          )
        end

        it 'does not copy the uninheritable fields from parent' do
          expect(subject.sku).to be nil
        end

        it 'does not overwrite uninheritable fields' do
          subject.sku = '12345'
          expect { subject.save }.to_not change { subject.sku }
        end

        context 'when moving subject' do
          before(:each) { subject.save! }

          let! :new_parent do
            model.create manufacturer: 'Samsung', name: 'Galaxy S', sku: '23456'
          end

          context 'to root' do
            it 'clears inherited fields' do
              expect { subject.update(parent: nil) }.to(
                change { subject.inherited_fields }
                .from(%w(name manufacturer)).to([])
              )
            end

            it 'retains the originally inherited values' do
              subject.update(parent: nil)

              expect(subject.manufacturer).to eq parent.manufacturer
              expect(subject.name).to eq parent.name
              expect(subject.sku).to eq nil
            end
          end

          context 'to another parent' do
            it 'does not change inherited fields' do
              expect { subject.update(parent: new_parent) }.to_not(
                change { subject.inherited_fields }
              )
            end

            it 'replaces values in inherited fields with that from the ' \
               'new parent' do
              subject.update(parent: new_parent)

              expect(subject.manufacturer).to eq new_parent.manufacturer
              expect(subject.name).to eq new_parent.name
              expect(subject.sku).to eq nil
            end
          end
        end
      end

      context 'with children' do
        subject do
          model.create manufacturer: 'Apple', name: 'iPhone', sku: '12345'
        end

        let! :child do
          subject.children.create inherited_fields: %w(manufacturer)
        end

        let! :grandchild do
          child.children.create inherited_fields: %w(manufacturer)
        end

        let! :grandgrandchild do
          grandchild.children.create inherited_fields: %w(manufacturer)
        end

        it 'propagates to inherited attribute in child' do
          expect { subject.update(manufacturer: 'Samsung') }.to change {
            child.reload.manufacturer
          }.from('Apple').to('Samsung')
        end

        it 'propagates to inherited attribute in grandchild' do
          expect { subject.update(manufacturer: 'HTC') }.to change {
            grandchild.reload.manufacturer
          }.from('Apple').to('HTC')
        end

        it 'propagates to inherited attribute in great-grandchild' do
          expect { subject.update(manufacturer: 'Google') }.to change {
            grandgrandchild.reload.manufacturer
          }.from('Apple').to('Google')
        end

        it 'does not update inheriting child if nothing has changed' do
          expect { subject.update(manufacturer: 'Apple') }.not_to change {
            child.reload.updated_at
          }
        end

        it 'does not propagate to non-inherited attributes of children' do
          expect { subject.update(name: 'iPad') }.not_to change {
            child.reload.name
          }
        end
      end
    end
  end
end
