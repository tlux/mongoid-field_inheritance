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

      field :inherited_fields, type: Array, default: []

      include Macro
      include Validation
      include Propagation
      include Dependency
      include Management

      before_validation :sanitize_inherited_fields

      alias_method :attribute_inherited?, :field_inherited?
    end

    def self.sanitize_field_names(fields)
      Array(fields).flatten.reject(&:blank?).map(&:to_s)
    end

    def field_inherited?(field)
      inherited_fields.include?(field.to_s)
    end

    private

    def sanitize_inherited_fields
      self.inherited_fields =
        Mongoid::FieldInheritance.sanitize_field_names(inherited_fields)
    end
  end
end

require 'mongoid/field_inheritance/inherit_option'
require 'mongoid/field_inheritance/macro'
require 'mongoid/field_inheritance/validation'
require 'mongoid/field_inheritance/propagation'
require 'mongoid/field_inheritance/dependency'
require 'mongoid/field_inheritance/management'
