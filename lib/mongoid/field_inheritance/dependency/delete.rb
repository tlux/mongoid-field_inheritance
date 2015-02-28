module Mongoid
  module FieldInheritance
    module Dependency
      ##
      # A strategy to delete all descendant document which prevents callbacks
      # from being invoked on the child documents.
      #
      # @since 0.1.0
      class Delete < Base
        def call
          document.descendants.delete_all
        end
      end
    end
  end
end
