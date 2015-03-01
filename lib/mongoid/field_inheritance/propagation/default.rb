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
        # A method responsible for copying data from a source document to the
        # inherited fields of a destination document.
        #
        # @param [Class] model The model which supports field inheritance.
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
        def self.call(field, source, destination)
          new(field, source, destination).call
        end

        ##
        # This method is responsible for copying data from the source to the
        # inherited fields of a destination document.
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
