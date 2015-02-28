require 'active_support/all'
require 'mongoid/tree'

module Mongoid
  ##
  # Module which will be included by models that want to use document-based
  # inheritance. The {Mongoid::Tree} module will be automatically included when
  # including this module.
  # @since 0.1.0
  module FieldInheritance
    extend ActiveSupport::Concern

    ##
    # An Array of fields that cannot be used for inheritance.
    INVALID_FIELDS = %w(_id _type created_at updated_at c_at u_at)

    included do
      include Mongoid::Tree
      extend Macro
      include Propagation
      include DependencyDestruction

      class_attribute :inheritable_fields, instance_accessor: false,
                                           instance_predicate: false
      self.inheritable_fields = []

      field :inherited_fields, type: Array, default: []

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

require 'mongoid/field_inheritance/macro'
require 'mongoid/field_inheritance/propagation'
require 'mongoid/field_inheritance/dependency_destruction'
