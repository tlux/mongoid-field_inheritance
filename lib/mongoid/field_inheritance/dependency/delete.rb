module Mongoid
  module FieldInheritance
    module Dependency
      ##
      # A strategy to delete all descendant document which prevents callbacks
      # from being invoked on the child documents.
      #
      # @since 0.1.0
      class Delete < Base
        ##
        # This method actually deletes all descendants, without invoking any
        # callbacks on the particular documents.
        #
        # @return [void]
        def call
          document.descendants.delete_all
        end
      end
    end
  end
end
