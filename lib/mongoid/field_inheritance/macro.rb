module Mongoid
  module FieldInheritance
    ##
    # Module which encapsulates all kinds of macro methods.
    #
    # @since 0.1.0
    module Macro
      extend ActiveSupport::Concern

      included do
        class_attribute :inheritable_fields, :inheritance_options
        self.inheritable_fields = {}
        self.inheritance_options = { dependent: :destroy }

        class << self
          alias_method_chain :create_accessors, :inheritance
        end
      end

      module ClassMethods
        ##
        # Allows defining options for inheritance.
        #
        # @options options [Hash] :dependent Controls what to do with child
        #   documents when destroying the parent. Possible values are :delete
        #   and :destroy. When nothing is defined the options defaults to
        #   :destroy.
        #
        # @example
        #   class Product
        #     include Mongoid::Document
        #     include Mongoid::FieldInheritance
        #
        #     inheritable dependent: :delete_all
        #
        #     field :manufacturer, inherit: true
        #     field :name
        #   end
        def inheritable(options)
          options.assert_valid_keys(:dependent)
          self.inheritance_options = inheritance_options.merge(options)
        end

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
    end
  end
end
