module Mongoid
  module FieldInheritance
    ##
    # An error to be raised when a field or a set of fields is not inheritable
    # for any kind of reason.
    #
    # @since 0.1.0
    class UninheritableError < StandardError
      attr_reader :model, :fields

      ##
      # Initializes the exception.
      #
      # @param [Class] model The model.
      # @param [Array<String>] fields The invalid fields.
      def initialize(model, *fields)
        @model = model
        @fields = fields.flatten
      end
    end
  end
end
