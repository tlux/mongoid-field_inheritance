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
      # Registers an inheritable field with a specific inheritor in a model.
      #
      # @param [Class] model The model.
      # @param [Symbol, String] name The name of the field.
      # @param [Symbol, #call] inheritor A Symbol referencing to an instance
      #   method of the model or a callable that defines an inheritance action.
      def self.register_inheritable_field(model, name, inheritor = nil)
        name = name.to_s
        field = model.fields[name]
        if field
          inheritor ||= Mongoid::FieldInheritance::Inheritor
        else
          fail ArgumentError, 'No inheritance rule defined'
        end
        Mongoid::FieldInheritance.validate_field!(field) if field
        model.inheritable_fields =
          model.inheritable_fields.merge(name => inheritor)
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
        # @param [Array<Symbol, String>] names One or more fields that will
        #   apply the defined inheritance logic.
        # @return
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
          inheritor = block || options[:with]
          names = FieldInheritance.sanitize_field_names(names)
          fail ArgumentError, 'No field defined' if names.empty?
          names.each do |name|
            Macros.register_inheritable_field(self, name, inheritor)
          end
        end
      end
    end
  end
end

Mongoid::Fields.option :inherit do |model, field, inheritor|
  if inheritor
    inheritor = Mongoid::FieldInheritance::Inheritor if inheritor == true
    Mongoid::FieldInheritance::Macros
      .register_inheritable_field(model, field.name, inheritor)
  end
end
