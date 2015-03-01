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
        before_validation :clear_inherited_fields,
                          if: [:root?, :parent_id_changed?]
        before_save :inherit_fields_from_parent, if: :parent?
        after_update :update_inherited_fields_in_children, if: :changed?
      end

      module ClassMethods
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
          inheritable_fields.each_value do |field|
            next unless destination.inherited_fields.include?(field.name)
            strategy_name = field.options[:inherit]
            next unless strategy_name
            strategy_name = :default if strategy_name == true
            strategy_class = const_get(strategy_name.to_s.classify)
            strategy_class.call(field, source, destination)
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

      def update_inherited_fields_in_children
        children.each do |child|
          self.class.copy_fields_for_inheritance(self, child)
          child.save!(validate: false)
        end
        true
      end
    end
  end
end

require 'mongoid/field_inheritance/propagation/default'
