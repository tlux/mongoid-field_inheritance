module Mongoid
  module FieldInheritance
    module Propagation
      ##
      # A class that provides basic functionality to copy attributes from a
      # source document to a destination.
      #
      # @since 0.1.0
      class DefaultStrategy < Base
        ##
        # This method is responsible for copying data from the source to the
        # inherited fields of a destination document.
        #
        # @return [void]
        def call
          if field.localized?
            destination["#{field.name}_translations"] =
              source["#{field.name}_translations"].deep_dup
          else
            destination[field.name] = source[field.name].deep_dup
          end
        end
      end
    end
  end
end
