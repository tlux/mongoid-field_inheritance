module Mongoid
  module FieldInheritance
    module Dependency
      ##
      # A strategy to destroy all children of the document which leads to
      # invocation of callbacks in all descending documents.
      #
      # @since 0.1.0
      class Destroy < Base
        def call
          document.children.destroy_all
        end
      end
    end
  end
end
