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
          create_inherited_accessor(name) if options[:inherit]
        end

        ##
        # Creates a name_inherited? method for each inheritable field, which
        # internally calls the {#field_inherited?} method. Undefines methods
        # of the same name, when existing.
        #
        # @param [Symbol, String] name The name of the field.
        def create_inherited_accessor(name)
          generated_methods.module_eval do
            re_define_method "#{name}_inherited?" do
              field_inherited?(name)
            end

            alias_method :"#{name}_inherited", :"#{name}_inherited?"

            re_define_method "#{name}_inherited=" do |inherited|
              mark_field_inherited(name, inherited)
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

      ##
      # Defines whether a single field is inherited. Internally uses
      # {Mongoid::FieldInheritance::Management#mark_inherited} and
      # {Mongoid::FieldInheritance::Management#mark_overridden} and is used
      # by the generated #field_inherited= setters.
      #
      # @param [Symbol, String] name The name of the field.
      # @param [Boolean] inherited Specifies whether the field is going to
      #   be inherited.
      # @return [Boolean] Returns true when the field is inherited,
      #   false otherwise.
      def mark_field_inherited(name, inherited)
        if Mongoid::Boolean.evolve(inherited)
          mark_inherited(name)
        else
          mark_overridden(name)
        end
        inherited
      end
    end
  end
end
