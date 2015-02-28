module Mongoid
  module FieldInheritance
    ##
    # This module controls inheritance of fields from parents and the
    # population of field values to children.
    #
    # @since 0.1.0
    module Propagation
      extend ActiveSupport::Concern

      included do
        before_validation :clear_inherited_fields,
                          if: [:root?, :parent_id_changed?]
        before_save :inherit_fields_from_parent, if: :parent?
        after_update :update_inherited_fields_in_children, if: :changed?
      end

      protected

      ##
      # A method responsible for copying data from a source document to the
      # inherited fields of a destination document.
      #
      # @param [Mongoid::Document] source The object from which fields
      #   will be copied.
      #
      # @param [Mongoid::Document] destination The object to which the
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
end

require 'mongoid/field_inheritance/propagation/default'
