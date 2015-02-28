module Mongoid
  module FieldInheritance
    module Dependency
      ##
      # A class providing an interface for all kinds of dependency handlers.
      #
      # @since 0.1.0
      class Base
        attr_reader :document

        def initialize(document)
          @document = document
        end

        def self.call(document)
          new(document).call
        end

        def call
          fail NotImplementedError, 'Dependency handler did not define what ' \
                                    'to do with descendants when destroying ' \
                                    'document'
        end
      end
    end
  end
end
