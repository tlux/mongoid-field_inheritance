module Mongoid
  module FieldInheritance
    ##
    # Module which encapsulates all kinds of macro methods.
    #
    # @since 0.1.0
    module Macros
      extend ActiveSupport::Concern

      included do
        class_attribute :inheritable_fields, :inheritance_options
        self.inheritable_fields = {}
        self.inheritance_options = { dependent: :destroy }
      end

      ##
      # @since 0.1.0
      module ClassMethods
        ##
        # Allows defining options for inheritance.
        #
        # @option options [Symbol] :dependent Controls what to do with child
        #   documents when destroying the parent. Possible values are :delete
        #   and :destroy. Defaults to :destroy when nothing is defined.
        # @return [Hash] The inheritance options.
        #
        # @example
        #   class Product
        #     include Mongoid::Document
        #     include Mongoid::FieldInheritance
        #
        #     acts_as_inheritable dependent: :delete_all
        #
        #     field :manufacturer, inherit: true
        #     field :name
        #   end
        def acts_as_inheritable(options = {})
          options.assert_valid_keys(:dependent)
          self.inheritance_options = inheritance_options.merge(options)
        end

        ##
        # A macro which allows defining custom inheritance logic on specific
        # fields or relations.
        #
        # @param [Array<Symbol, String>] names One or multiple fields that
        #   will apply the defined inheritance logic.
        # @yield [name, source, destination] Defines what to do when inheriting
        #   the specified fields.
        # @yieldparam [Symbol] name The name of the inherited field, accessor,
        #   or relation.
        # @yieldparam [Mongoid::Document] source The document from which the
        #   values are copied.
        # @yieldparam [Mongoid::Document] destination The document to which the
        #   values are copied.
        # @yieldreturn [void]
        def inherit(*names, &block)
          options = names.extract_options!
          inheritor = block || options[:with] || Inheritor
          names = Mongoid::FieldInheritance.sanitize_field_names(names)
          names.each do |name|
            self.inheritable_fields =
              inheritable_fields.merge(name.to_s => inheritor)
          end
        end
      end
    end
  end
end

Mongoid::Fields.option :inherit do |model, field, value|
  if value
    if field.name.in?(Mongoid::FieldInheritance::INVALID_FIELDS)
      fail Mongoid::FieldInheritance::UninheritableError.new(model, field),
           "Field is not inheritable: #{field.name}"
    end
    model.inheritable_fields =
      model.inheritable_fields.merge(field.name => field)
  end
end
