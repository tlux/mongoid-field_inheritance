module Mongoid
  module FieldInheritance
    module Propagation
      class Default
        attr_reader :model, :source, :destination

        def initialize(model, source, destination)
          @model = model
          @source = source
          @destination = destination
        end

        def self.call(model, source, destination)
          new(model, source, destination).call
        end

        def call
          fields = destination.inherited_fields
          model.localized_fields.each_key do |localized_field|
            if fields.delete(localized_field)
              fields << "#{localized_field}_translations"
            end
          end
          destination.attributes = source.send(:clone_document).slice(*fields)
        end
      end
    end
  end
end
