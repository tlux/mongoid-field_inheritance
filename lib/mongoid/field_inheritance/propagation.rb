module Mongoid
  module FieldInheritance
    ##
    # This module controls inheritance of fields from parent documents and the
    # population of field values to child documents.
    #
    # @since 0.1.0
    module Propagation
      extend ActiveSupport::Concern

      included do
        define_model_callbacks :inherit, :propagate

        before_validation :clear_inherited_fields,
                          if: [:root?, :parent_id_changed?]
        before_save :inherit_fields_from_parent, if: :parent?
        after_update :propagate_fields_to_children, if: :changed?
      end

      ##
      # @since 0.1.0
      module ClassMethods
        ##
        # A method responsible for copying data from a source document to the
        # inherited fields of a destination document.
        #
        # @param [Mongoid::Document] source The object from which fields
        #   will be copied.
        # @param [Mongoid::Document] destination The object to which the
        #   fields will be copied.
        # @return [void]
        def copy_fields_for_inheritance(source, destination)
          if source.inheritable_fields != destination.inheritable_fields
            fail ArgumentError, 'Documents are not compatible for inheritance'
          end
          source.run_callbacks :propagate do
            destination.run_callbacks :inherit do
              destination.inherited_fields.each do |name|
                field = inheritable_fields[name.to_s]
                next if field.nil? || !field.options[:inherit]
                Inheritor.call(field, source, destination)
              end
            end
          end
        end
      end

      private

      def clear_inherited_fields
        self.inherited_fields = []
      end

      def inherit_fields_from_parent
        self.class.copy_fields_for_inheritance(parent, self)
      end

      def propagate_fields_to_children
        children.each do |child|
          self.class.copy_fields_for_inheritance(self, child)
          child.save!(validate: false)
        end
        true
      end
    end
  end
end
