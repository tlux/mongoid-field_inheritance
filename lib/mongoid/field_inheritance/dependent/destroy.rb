module Mongoid
  module FieldInheritance
    module Dependent
      ##
      # A strategy to destroy all children of the document which leads to
      # invocation of callbacks in all descending documents.
      #
      # @since 0.1.0
      class Destroy < Base
        ##
        # This method destroys all children (recursively), invoking callbacks
        # on the particular documents.
        #
        # @return [void]
        def call
          document.children.destroy_all
        end
      end
    end
  end
end
