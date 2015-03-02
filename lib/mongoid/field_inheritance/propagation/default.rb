module Mongoid
  module FieldInheritance
    module Propagation
      ##
      # A class that provides basic functionality to copy attributes from a
      # source document to a destination.
      #
      # @since 0.1.0
      class Default < Base
        ##
        # This method is responsible for copying data from the source to the
        # inherited fields of a destination document.
        #
        # @return [void]
        def call
          if field.localized?
            translations = source.public_send("#{field.name}_translations")
                           .deep_dup
            destination.public_send("#{field.name}_translations=", translations)
          else
            destination[field.name] = source[field.name].deep_dup
          end
        end
      end
    end
  end
end
