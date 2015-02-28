module Mongoid
  module FieldInheritance
    ##
    # This module validates whether a document's inheritance settings are valid.
    #
    # @since 0.1.0
    module Validation
      extend ActiveSupport::Concern

      included do
        validate :verify_inherited_fields_are_empty, if: :root?
        validate :verify_inherited_fields_are_inheritable_fields,
                 if: :inherited_fields_changed?
      end

      private

      def verify_inherited_fields_are_inheritable_fields
        if inherited_fields.any? { |f| !f.in?(self.class.inheritable_fields) }
          errors.add :inherited_fields, :invalid
        end
        true
      end

      def verify_inherited_fields_are_empty
        return true if inherited_fields.empty?
        errors.add :inherited_fields, :unavailable
      end
    end
  end
end
