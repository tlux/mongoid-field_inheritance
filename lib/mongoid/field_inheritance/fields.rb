module Mongoid
  module FieldInheritance
    module Fields
      extend ActiveSupport::Concern

      included do
        alias_method :attribute_inherited?, :field_inherited?

        class << self
          alias_method_chain :create_accessors, :inheritance
        end
      end

      module ClassMethods
        protected

        def create_accessors_with_inheritance(name, meth, options = {})
          create_accessors_without_inheritance(name, meth, options)
          create_inherited_check(name) if options[:inherit]
        end

        def create_inherited_check(name)
          generated_methods.module_eval do
            re_define_method "#{name}_inherited?" do
              attribute_inherited?(name)
            end
          end
        end
      end

      ##
      # Indicates whether a field is inherited. It actually checks whether a
      # given field is included in #inherited_fields of the current document.
      # Aliased as: #attribute_inherited?
      #
      # @param [Symbol, String] field The name of the field.
      # @return [Boolean] Returns true when the field is inherited,
      #   false otherwise.
      def field_inherited?(field)
        inherited_fields.include?(field.to_s)
      end
    end
  end
end

Mongoid::Fields.option :inherit do |model, field, value|
  if field.name.in?(Mongoid::FieldInheritance::INVALID_FIELDS)
    fail Mongoid::FieldInheritance::UninheritableError.new(model, field),
         "Field is not inheritable: #{field.name}"
  end
  model.inheritable_fields = model.inheritable_fields.merge(field.name => field)
end
