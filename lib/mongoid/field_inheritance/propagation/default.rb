module Mongoid
  module FieldInheritance
    module Propagation
      ##
      # A class that provides basic functionality to copy attributes from a
      # source document to a destination.
      #
      # @since 0.1.0
      class Default
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
