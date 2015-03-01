module Mongoid
  module FieldInheritance
    module Propagation
      ##
      # A class providing an interface for all kinds of propagation handlers.
      #
      # @since 0.1.0
      class Base
        attr_reader :field, :source, :destination

        ##
        # Initializes the propagation strategy class.
        #
        # @param [Mongoid::Fields::Standard] field The field to be copied.
        # @param [Mongoid::Document] source The object from which fields
        #   will be copied.
        # @param [Mongoid::Document] destination The object to which the
        #   field will be copied.
        def initialize(field, source, destination)
          @field = field
          @source = source
          @destination = destination
        end

        # This method will initialize a new instance of the current class,
        # forward the given parameters to the initializer, and invoke the
        # #call method.
        #
        # @param [Mongoid::Fields::Standard] field The field to be copied.
        # @param [Mongoid::Document] source The object from which fields
        #   will be copied.
        # @param [Mongoid::Document] destination The object to which the
        #   field will be copied.
        #
        # @return [void]
        def self.call(field, source, destination)
          new(field, source, destination).call
        end

        ##
        # This method is responsible for copying data from the source to the
        # inherited fields of a destination document.
        #
        # @raise [NotImplementedError] Method must be implemented by subclasses.
        def call
          fail NotImplementedError, 'Propagation strategy does not implement ' \
                                    'any action'
        end
      end
    end
  end
end
