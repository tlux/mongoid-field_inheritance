require 'active_support/all'
require 'mongoid/tree'

module Mongoid
  ##
  # Module which will be included by models that want to use document-based
  # inheritance. {Mongoid::Tree} will be automatically included when
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

      include Macros
      include Fields
      include Validation
      include Propagation
      include Dependent
      include Management

      before_validation :sanitize_inherited_fields
    end

    ##
    # Wraps an Array around the given argument, flattens it and removes
    # blank values. Finally the array elements are converted to Strings.
    #
    # @param [Array<Symbol, String>] fields The field or fields
    #   to be sanitized.
    # @return [Array<String>] A list of field names.
    def self.sanitize_field_names(*fields)
      Array(fields).flatten.reject(&:blank?).map(&:to_s)
    end

    private

    ##
    # Is invoked before validation to clean up inherited_fields.
    #
    # @return [void]
    def sanitize_inherited_fields
      self.inherited_fields =
        Mongoid::FieldInheritance.sanitize_field_names(inherited_fields)
    end
  end
end

require 'mongoid/field_inheritance/macros'
require 'mongoid/field_inheritance/fields'
require 'mongoid/field_inheritance/validation'
require 'mongoid/field_inheritance/propagation'
require 'mongoid/field_inheritance/dependent'
require 'mongoid/field_inheritance/management'
require 'mongoid/field_inheritance/uninheritable_error'
require 'mongoid/field_inheritance/undefined_parent_error'
