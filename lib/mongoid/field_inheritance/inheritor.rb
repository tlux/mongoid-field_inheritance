module Mongoid
  module FieldInheritance
    ##
    # A basic inheritor that copies field contents from a source document
    # to a destination document.
    module Inheritor
      extend self

      ##
      # A method responsible for copying a single field from a source document
      # to a destination document.
      #
      # @param [Mongoid::Fields::Standard] field Thee field to be copied.
      # @param [Mongoid::Document] source The object from which field
      #   will be copied.
      # @param [Mongoid::Document] destination The object to which the
      #   field will be copied.
      # @return [void]
      def call(field, source, destination)
        if field.localized?
          translations_attr = "#{field.name}_translations"
          translations = source.public_send(translations_attr).deep_dup
          destination.public_send("#{translations_attr}=", translations)
        else
          destination[field.name] = source[field.name].deep_dup
        end
      end
    end
  end
end
