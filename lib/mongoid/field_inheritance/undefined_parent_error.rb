module Mongoid
  module FieldInheritance
    ##
    # An error to be raised when a document does not have a parent to inherit
    # from.
    #
    # @since 0.1.0
    class UndefinedParentError < StandardError
      attr_reader :document

      ##
      # Initializes the exception.
      #
      # @param [Mongoid::Document] document The document without a parent.
      def initialize(document)
        @document = document
      end
    end
  end
end
