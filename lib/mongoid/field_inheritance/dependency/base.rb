module Mongoid
  module FieldInheritance
    module Dependency
      ##
      # A class providing an interface for all kinds of dependency handlers.
      #
      # @since 0.1.0
      class Base
        attr_reader :document

        ##
        # Initializes the dependency strategy class.
        #
        # @param [Mongoid::Document] document The document which descendants
        #   are going to be processed by this strategy.
        def initialize(document)
          @document = document
        end

        ##
        # This method is responsible for perfoming an actual action on the
        # descendant documents.
        #
        # @param [Mongoid::Document] document The document which descendants
        #   are going to be processed by this strategy.
        #
        # @return [void]
        def self.call(document)
          new(document).call
        end

        ##
        # This method is responsible for perfoming an actual action on the
        # descendant documents.
        #
        # @return [void]
        def call
          fail NotImplementedError, 'Dependency handler did not define what ' \
                                    'to do with descendants when destroying ' \
                                    'document'
        end
      end
    end
  end
end