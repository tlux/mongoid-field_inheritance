module Mongoid
  module FieldInheritance
    ##
    # Provides hooks to create inheritance based inquiry methods and all kinds
    # of other field-related stuff.
    #
    # @since 0.1.0
    module Fields
      extend ActiveSupport::Concern

      included do
        alias_method :attribute_inherited?, :field_inherited?

        class << self
          alias_method_chain :create_accessors, :inheritance
        end
      end

      ##
      # @since 0.1.0
      module ClassMethods
        protected

        ##
        # Creates accessors for a field when loading the model class. This
        # version hooks into the original implementation to create additional
        # helper methods for field inheritance.
        #
        # @param [Symbol, String] name The name of the field.
        # @param [Symbol] meth The name of the method.
        # @option options [Boolean] :inherit Determines whether the field is
        #   inheritable, which creates inheritance specific methods.
        # @return [void]
        def create_accessors_with_inheritance(name, meth, options = {})
          create_accessors_without_inheritance(name, meth, options)
          create_inherited_check(name) if options[:inherit]
        end

        ##
        # Creates a name_inherited? method for each inheritable field, which
        # internally calls the {#field_inherited?} method. Undefines methods
        # of the same name, when existing.
        #
        # @param [Symbol, String] name The name of the field.
        def create_inherited_check(name)
          generated_methods.module_eval do
            re_define_method "#{name}_inherited?" do
              field_inherited?(name)
            end
          end
        end
      end

      ##
      # Indicates whether a field is inherited. It actually checks whether a
      # given field is included in #inherited_fields of the current document.
      # Aliased as: #attribute_inherited?
      #
      # @param [Symbol, String] name The name of the field.
      # @return [Boolean] Returns true when the field is inherited,
      #   false otherwise.
      def field_inherited?(name)
        inherited_fields.include?(name.to_s)
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
