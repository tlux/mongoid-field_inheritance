module Mongoid
  module FieldInheritance
    ##
    # This module validates whether a document's inheritance settings are valid.
    #
    # @since 0.1.0
    module Validation
      extend ActiveSupport::Concern

      included do
        validate :verify_inherited_fields_are_empty
        validate :verify_inherited_fields_are_inheritable_fields,
                 if: :inherited_fields_changed?
      end

      private

      ##
      # Validates whether all fields in inherited_fields match the fields
      # permited through inheritable_fields. Adds an error to the document
      # otherwise.
      #
      # @return [void]
      def verify_inherited_fields_are_inheritable_fields
        invalid_field = inherited_fields.detect do |f|
          !f.in?(self.class.inheritable_fields)
        end
        return unless invalid_field
        errors.add :inherited_fields, :invalid,
                   field: invalid_field,
                   name: self.class.human_attribute_name(invalid_field)
      end

      ##
      # Validates whether no inherited_fields have been set. This is relevant
      # when the document is on the root of the hierarchy. Adds an error to the
      # document if inherited_fields exist.
      #
      # @return [void]
      def verify_inherited_fields_are_empty
        return if !root? || inherited_fields.empty?
        errors.add :inherited_fields, :unavailable
      end
    end
  end
end
