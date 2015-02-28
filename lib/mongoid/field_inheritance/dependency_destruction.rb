module Mongoid
  module FieldInheritance
    ##
    # This module handles the destruction of descendant documents.
    #
    # @since 0.1.0
    module DependencyDestruction
      extend ActiveSupport::Concern

      included do
        class_attribute :destroy_inherited_via, instance_accessor: false,
                                                instance_predicate: false
        self.destroy_inherited_via = :destroy

        before_destroy :destroy_inherited_documents
      end

      protected

      ##
      # A hook that is responsible for removing documents that are nested
      # within the current one. Destroys the documents by default so that
      # callbacks defined in children become invoked.
      def destroy_inherited_documents
        if self.class.destroy_inherited_via == :delete
          descendants.delete_all
        else
          children.destroy_all
        end
      end
    end
  end
end
