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
      include DependencyDestruction

      class_attribute :inheritable_fields, instance_accessor: false,
                                           instance_predicate: false
      self.inheritable_fields = []

      field :inherited_fields, type: Array, default: []

      before_validation :clear_inherited_fields,
                        if: [:root?, :parent_id_changed?]
      before_save :inherit_fields_from_parent, if: :parent?
      after_update :update_inherited_fields_in_children, if: :changed?

      validate :verify_inherited_fields_are_empty_for_root, if: :root?
      validate :verify_inherited_fields_are_inheritable_fields,
               if: :inherited_fields_changed?
    end

    protected

    ##
    # A method responsible for copying data from a source document to the
    # inherited fields of a destination document.
    #
    # @param [Mongoid::FieldInheritance] source The object from which fields
    #   will be copied.
    #
    # @param [Mongoid::FieldInheritance] destination The object to which the
    #   field will be copied.
    def copy_fields_for_inheritance(source, destination)
      fields = destination.inherited_fields
      localized_fields.each_key do |localized_field|
        if fields.delete(localized_field)
          fields << "#{localized_field}_translations"
        end
      end
      destination.attributes = source.send(:clone_document).slice(*fields)
    end

    private

    def verify_inherited_fields_are_inheritable_fields
      if inherited_fields.any? { |f| !f.in?(self.class.inheritable_fields) }
        errors.add :inherited_fields, :invalid
      end
      true
    end

    def verify_inherited_fields_are_empty_for_root
      errors.add :inherited_fields, :unavailable if inherited_fields.any?
    end

    def clear_inherited_fields
      self.inherited_fields = []
    end

    def inherit_fields_from_parent
      copy_fields_for_inheritance(parent, self)
    end

    def update_inherited_fields_in_children
      children.each do |child|
        copy_fields_for_inheritance(self, child)
        child.save!(validate: false)
      end
      true
    end
  end
end

require 'mongoid/field_inheritance/macro'
require 'mongoid/field_inheritance/dependency_destruction'
