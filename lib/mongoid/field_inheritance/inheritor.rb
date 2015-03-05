module Mongoid
  module FieldInheritance
    ##
    # A basic inheritor that copies field contents from a source document
    # to a destination document.
    module Inheritor
      module_function

      ##
      # A method responsible for copying a single field from a source document
      # to a destination document.
      #
      # @param [Symbol] name The field to be copied.
      # @param [Mongoid::Document] source The object from which the field
      #   will be copied.
      # @param [Mongoid::Document] destination The object to which the
      #   field will be copied.
      # @return [void]
      def call(name, source, destination)
        field = destination.fields[name.to_s]
        fail ArgumentError, "Unknown field: #{name}" if field.nil?
        if field.localized?
          translations_attr = "#{name}_translations"
          translations = source.public_send(translations_attr).deep_dup
          destination.public_send("#{translations_attr}=", translations)
        else
          destination[name] = source[name].deep_dup
        end
      end
    end
  end
end
