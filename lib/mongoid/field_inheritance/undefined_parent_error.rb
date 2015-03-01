module Mongoid
  module FieldInheritance
    class UndefinedParentError < StandardError
      attr_reader :document

      def initialize(document)
        @document = document
      end
    end
  end
end
