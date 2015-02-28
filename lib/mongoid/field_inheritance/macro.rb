module Mongoid
  module FieldInheritance
    ##
    # Module which encapsulates all kinds of macro methods.
    #
    # @since 0.1.0
    module Macro
      ##
      # Defines the fields that should be recognized as inheritable to
      # the children of a document. Adds the all fields to the
      # inheritable_fields class attribute and creates #field_inherited?
      # instance methods if valid.
      #
      # @param [Array<String, Symbol>] fields Fields in the current class that
      #   will be marked inheritable, either specified as a list of arguments
      #   or an Array of Strings or Symbols.
      #
      # @return [Array<String>] All fields of the current class and ancestors
      #   that are marked inheritable.
      #
      # @raise [ArgumentError] Will raise if no fields have been specified or
      #   any of the given fields is invalid (_id, _type, created_at,
      #   updated_at, c_at, or u_at).
      #
      # @example
      #   class Product
      #     include Mongoid::Document
      #     include Mongoid::FieldInheritance
      #
      #     field :manufacturer
      #     field :name
      #
      #     self.delete_descendants = true
      #
      #     inherits :manufacturer, :name
      #   end
      def inherits(*fields)
        fields = Mongoid::FieldInheritance.sanitize_field_names(fields)
        fail ArgumentError, 'No inheritable fields defined' if fields.empty?
        invalid_field = fields.detect { |f| f.in?(INVALID_FIELDS) }
        if invalid_field
          fail ArgumentError, "Field may not be inherited: #{invalid_field}"
        end

        self.inheritable_fields += fields

        with_inheritable_fields_in_current_and_inheriting_classes do |field|
          define_method :"#{field}_inherited?" do
            attribute_inherited?(field)
          end
        end

        inheritable_fields
      end

      ##
      # Removes all fields from the inheritable fields.
      #
      # @example
      #   class Product
      #     include Mongoid::Document
      #     include Mongoid::FieldInheritance
      #
      #     field :name
      #     inherits :name
      #   end
      #
      #   class Device < Product
      #     reset_inheritance
      #   end
      def reset_inheritance
        with_inheritable_fields_in_current_and_inheriting_classes do |field|
          if instance_methods.include?(:"#{field}_inherited?")
            remove_method(:"#{field}_inherited?")
          end
        end
        inheritable_fields.clear
      end

      private

      def with_inheritable_fields_in_current_and_inheriting_classes(&block)
        inheritable_fields.each do |inheritable_field|
          [self, *descendants].each do |klass|
            klass.instance_exec(inheritable_field, &block)
          end
        end
      end
    end
  end
end
